import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/prayer_request_model.dart';
import '../../services/prayer_service.dart';
import '../../utils/validators.dart';

class SubmitPrayerScreen extends StatefulWidget {
  const SubmitPrayerScreen({super.key});

  @override
  State<SubmitPrayerScreen> createState() => _SubmitPrayerScreenState();
}

class _SubmitPrayerScreenState extends State<SubmitPrayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prayerService = PrayerService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  PrayerCategory _selectedCategory = PrayerCategory.general;
  PrayerPrivacy _selectedPrivacy = PrayerPrivacy.public;
  bool _isUrgent = false;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitPrayer() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.currentUser == null) {
          throw Exception('User not authenticated');
        }

        if (authProvider.currentUser!.currentChurchId == null) {
          throw Exception('Please join a church first');
        }

        await _prayerService.submitPrayerRequest(
          userId: authProvider.currentUser!.id,
          userName: authProvider.currentUser!.name,
          userPhotoUrl: authProvider.currentUser!.photoUrl,
          churchId: authProvider.currentUser!.currentChurchId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          privacy: _selectedPrivacy,
          isUrgent: _isUrgent,
          isAnonymous: _isAnonymous,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prayer request submitted! The church will pray for you.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
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
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Prayer Request'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Share your prayer request with your church family. We will pray with you and for you.',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Prayer Title *',
                  hintText: 'Brief title for your prayer request',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, fieldName: 'Title'),
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Prayer Request *',
                  hintText: 'Share what you need prayer for...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) => Validators.validateRequired(value,
                    fieldName: 'Prayer request'),
              ),
              const SizedBox(height: 24),

              // Category
              DropdownButtonFormField<PrayerCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: PrayerCategory.values.map((category) {
                  final prayer = PrayerRequestModel(
                    id: '',
                    userId: '',
                    userName: '',
                    churchId: '',
                    title: '',
                    description: '',
                    category: category,
                    createdAt: DateTime.now(),
                  );
                  return DropdownMenuItem(
                    value: category,
                    child: Text(prayer.categoryDisplay),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Privacy
              const Text(
                'Who can see this prayer? *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...PrayerPrivacy.values.map((privacy) {
                final prayer = PrayerRequestModel(
                  id: '',
                  userId: '',
                  userName: '',
                  churchId: '',
                  title: '',
                  description: '',
                  category: PrayerCategory.general,
                  privacy: privacy,
                  createdAt: DateTime.now(),
                );
                return RadioListTile<PrayerPrivacy>(
                  title: Text(prayer.privacyDisplay),
                  subtitle: Text(_getPrivacyDescription(privacy)),
                  value: privacy,
                  groupValue: _selectedPrivacy,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPrivacy = value;
                      });
                    }
                  },
                );
              }),
              const SizedBox(height: 16),

              // Options
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Mark as Urgent'),
                      subtitle: const Text(
                          'Highlight this prayer for immediate attention'),
                      value: _isUrgent,
                      onChanged: (value) {
                        setState(() {
                          _isUrgent = value;
                        });
                      },
                      secondary: const Icon(Icons.priority_high, color: Colors.red),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Submit Anonymously'),
                      subtitle: const Text('Your name will not be shown'),
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value;
                        });
                      },
                      secondary: const Icon(Icons.visibility_off),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitPrayer,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Prayer Request'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Bible Verse
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God."',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- Philippians 4:6',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPrivacyDescription(PrayerPrivacy privacy) {
    switch (privacy) {
      case PrayerPrivacy.public:
        return 'Everyone in the church can see and pray';
      case PrayerPrivacy.private:
        return 'Only you and church leadership can see';
      case PrayerPrivacy.leadership:
        return 'Only church leaders can see this prayer';
    }
  }
}
