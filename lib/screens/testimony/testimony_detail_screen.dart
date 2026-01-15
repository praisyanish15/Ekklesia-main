import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../models/testimony_model.dart';
import '../../services/testimony_service.dart';

class TestimonyDetailScreen extends StatefulWidget {
  final TestimonyModel testimony;

  const TestimonyDetailScreen({super.key, required this.testimony});

  @override
  State<TestimonyDetailScreen> createState() => _TestimonyDetailScreenState();
}

class _TestimonyDetailScreenState extends State<TestimonyDetailScreen> {
  final _testimonyService = TestimonyService();
  late TestimonyModel _testimony;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _testimony = widget.testimony;
    _loadTestimonyData();
  }

  Future<void> _loadTestimonyData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      // Check if user has liked
      final liked = await _testimonyService.hasUserLiked(
        _testimony.id,
        authProvider.currentUser!.id,
      );
      setState(() {
        _isLiked = liked;
      });
    }

    // Increment view count
    await _testimonyService.incrementViewCount(_testimony.id);
  }

  Future<void> _toggleLike() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    try {
      if (_isLiked) {
        await _testimonyService.unlikeTestimony(
          _testimony.id,
          authProvider.currentUser!.id,
        );
        setState(() {
          _isLiked = false;
          _testimony = _testimony.copyWith(
            likeCount: _testimony.likeCount - 1,
          );
        });
      } else {
        await _testimonyService.likeTestimony(
          _testimony.id,
          authProvider.currentUser!.id,
        );
        setState(() {
          _isLiked = true;
          _testimony = _testimony.copyWith(
            likeCount: _testimony.likeCount + 1,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareTestimony() {
    Share.share(
      '${_testimony.title}\n\n'
      '${_testimony.content}\n\n'
      '- ${_testimony.userName}\n'
      'Category: ${_testimony.categoryDisplay}\n\n'
      'Shared from Ekklesia Testimony Vault',
      subject: _testimony.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testimony'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareTestimony,
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
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_testimony.isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber[800]),
                          const SizedBox(width: 6),
                          Text(
                            'Featured Testimony',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    _testimony.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: _testimony.userPhotoUrl != null
                            ? NetworkImage(_testimony.userPhotoUrl!)
                            : null,
                        child: _testimony.userPhotoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _testimony.userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('MMMM d, yyyy')
                                  .format(_testimony.createdAt),
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

            // Category
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Chip(
                avatar: Icon(_getCategoryIcon(), size: 18),
                label: Text(_testimony.categoryDisplay),
                backgroundColor: Colors.blue[100],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _testimony.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),

            // Audio Player (if audio testimony)
            if (_testimony.type == TestimonyType.audio &&
                _testimony.audioUrl != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.audiotrack, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text('Audio Testimony'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            // TODO: Implement audio player
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Audio player coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Video Player (if video testimony)
            if (_testimony.type == TestimonyType.video &&
                _testimony.videoUrl != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam, color: Colors.blue),
                        const SizedBox(width: 12),
                        const Text('Video Testimony'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            // TODO: Implement video player
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Video player coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Like and Share Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton.filled(
                    onPressed: _toggleLike,
                    icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: _isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_testimony.likeCount} ${_testimony.likeCount == 1 ? 'like' : 'likes'}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _shareTestimony,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"They triumphed by the blood of the Lamb and by the word of their testimony; they did not love their lives so much as to shrink from death."',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '- Revelation 12:11',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (_testimony.category) {
      case TestimonyCategory.healing:
        return Icons.healing;
      case TestimonyCategory.financialBreakthrough:
        return Icons.attach_money;
      case TestimonyCategory.salvation:
        return Icons.favorite;
      case TestimonyCategory.deliverance:
        return Icons.check_circle;
      case TestimonyCategory.provision:
        return Icons.card_giftcard;
      case TestimonyCategory.protection:
        return Icons.shield;
      case TestimonyCategory.answeredPrayer:
        return Icons.check_circle_outline;
      default:
        return Icons.auto_awesome;
    }
  }
}
