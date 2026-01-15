import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../models/prayer_request_model.dart';
import '../../services/prayer_service.dart';

class PrayerDetailScreen extends StatefulWidget {
  final PrayerRequestModel prayer;

  const PrayerDetailScreen({super.key, required this.prayer});

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  final _prayerService = PrayerService();
  final _testimonyController = TextEditingController();
  late PrayerRequestModel _prayer;
  bool _hasPrayed = false;

  @override
  void initState() {
    super.initState();
    _prayer = widget.prayer;
  }

  @override
  void dispose() {
    _testimonyController.dispose();
    super.dispose();
  }

  Future<void> _handleIPrayed() async {
    try {
      await _prayerService.incrementPrayerCount(_prayer.id);
      setState(() {
        _hasPrayed = true;
        _prayer = _prayer.copyWith(
          prayerCount: _prayer.prayerCount + 1,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Thank you for praying!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAnsweredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prayer Answered!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Praise God! Please share how this prayer was answered:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testimonyController,
              decoration: const InputDecoration(
                hintText: 'Share your testimony...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_testimonyController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please share how the prayer was answered'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _markAsAnswered();
            },
            child: const Text('Mark as Answered'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsAnswered() async {
    try {
      await _prayerService.markAsAnswered(
        prayerId: _prayer.id,
        testimony: _testimonyController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer marked as answered! Glory to God!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Ask if they want to convert to testimony
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _showConvertToTestimonyDialog();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConvertToTestimonyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share as Testimony?'),
        content: const Text(
          'Would you like to share this answered prayer as a testimony to encourage others?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _convertToTestimony();
            },
            child: const Text('Yes, Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _convertToTestimony() async {
    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }

      await _prayerService.convertToTestimony(
        prayerId: _prayer.id,
        userId: authProvider.currentUser!.id,
        userName: authProvider.currentUser!.name,
        userPhotoUrl: authProvider.currentUser!.photoUrl,
        churchId: _prayer.churchId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Testimony submitted! It will appear after admin approval.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sharePrayer() {
    Share.share(
      'Prayer Request: ${_prayer.title}\n\n'
      '${_prayer.description}\n\n'
      'Category: ${_prayer.categoryDisplay}\n'
      'Please join me in prayer.\n\n'
      'From Ekklesia ShepherdCare',
      subject: _prayer.title,
    );
  }

  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Prayer'),
        content: const Text(
          'Are you sure you want to archive this prayer request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _archivePrayer();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  Future<void> _archivePrayer() async {
    try {
      await _prayerService.archivePrayer(_prayer.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer archived'),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final isOwnPrayer = authProvider.currentUser?.id == _prayer.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Request'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePrayer,
          ),
          if (isOwnPrayer && _prayer.status == PrayerStatus.active)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'answered') {
                  _showAnsweredDialog();
                } else if (value == 'archive') {
                  _showArchiveDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'answered',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Mark as Answered'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Archive'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: _prayer.status == PrayerStatus.answered
                  ? Colors.green[50]
                  : Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_prayer.status == PrayerStatus.answered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green[800]),
                          const SizedBox(width: 6),
                          Text(
                            'Prayer Answered',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_prayer.isUrgent && _prayer.status == PrayerStatus.active)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high,
                              size: 16, color: Colors.red[800]),
                          const SizedBox(width: 6),
                          Text(
                            'Urgent Prayer Request',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    _prayer.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: _prayer.userPhotoUrl != null
                            ? NetworkImage(_prayer.userPhotoUrl!)
                            : null,
                        child: _prayer.userPhotoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _prayer.userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('MMMM d, yyyy')
                                  .format(_prayer.createdAt),
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category & Privacy
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Chip(
                    avatar: Icon(_getCategoryIcon(), size: 18),
                    label: Text(_prayer.categoryDisplay),
                    backgroundColor: Colors.blue[100],
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(
                      _prayer.privacy == PrayerPrivacy.public
                          ? Icons.public
                          : _prayer.privacy == PrayerPrivacy.private
                              ? Icons.lock
                              : Icons.admin_panel_settings,
                      size: 18,
                    ),
                    label: Text(_prayer.privacyDisplay),
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prayer Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _prayer.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // Answered Testimony
            if (_prayer.answeredTestimony != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'How God Answered',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _prayer.answeredTestimony!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        if (_prayer.answeredAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Answered on ${DateFormat('MMMM d, yyyy').format(_prayer.answeredAt!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Prayer Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.people, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${_prayer.prayerCount} ${_prayer.prayerCount == 1 ? 'person has' : 'people have'} prayed for this',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"Therefore I tell you, whatever you ask for in prayer, believe that you have received it, and it will be yours."',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '- Mark 11:24',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _prayer.status == PrayerStatus.active
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _hasPrayed ? null : _handleIPrayed,
                  icon: Icon(_hasPrayed ? Icons.check_circle : Icons.prayer_times),
                  label: Text(
                    _hasPrayed ? 'You have prayed for this' : 'I Prayed for This',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        _hasPrayed ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  IconData _getCategoryIcon() {
    switch (_prayer.category) {
      case PrayerCategory.general:
        return Icons.chat_bubble_outline;
      case PrayerCategory.health:
        return Icons.healing;
      case PrayerCategory.family:
        return Icons.family_restroom;
      case PrayerCategory.financial:
        return Icons.attach_money;
      case PrayerCategory.spiritual:
        return Icons.auto_awesome;
      case PrayerCategory.other:
        return Icons.more_horiz;
    }
  }
}
