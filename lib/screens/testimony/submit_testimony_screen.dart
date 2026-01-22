import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/testimony_model.dart';
import '../../services/testimony_service.dart';
import '../../utils/validators.dart';

class SubmitTestimonyScreen extends StatefulWidget {
  const SubmitTestimonyScreen({super.key});

  @override
  State<SubmitTestimonyScreen> createState() => _SubmitTestimonyScreenState();
}

class _SubmitTestimonyScreenState extends State<SubmitTestimonyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _testimonyService = TestimonyService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  TestimonyCategory _selectedCategory = TestimonyCategory.healing;
  TestimonyType _selectedType = TestimonyType.text;
  File? _audioFile;
  File? _videoFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _audioFile = File(result.files.first.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileSize = await file.length();

        // Check file size (max 100MB for video)
        if (fileSize > 100 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video file is too large (max 100MB)'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _videoFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitTestimony() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validation based on type
      if (_selectedType == TestimonyType.audio && _audioFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an audio file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedType == TestimonyType.video && _videoFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a video file'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.currentUser == null) {
          throw Exception('User not authenticated');
        }

        await _testimonyService.submitTestimony(
          userId: authProvider.currentUser!.id,
          userName: authProvider.currentUser!.name,
          userPhotoUrl: authProvider.currentUser!.photoUrl,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          type: _selectedType,
          audioFile: _audioFile,
          videoFile: _videoFile,
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
        title: const Text('Share Your Testimony'),
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
                      Icon(Icons.auto_awesome, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '"They triumphed by the blood of the Lamb and by the word of their testimony" - Rev 12:11',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Testimony Type
              const Text(
                'Testimony Format *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TestimonyType>(
                segments: const [
                  ButtonSegment(
                    value: TestimonyType.text,
                    label: Text('Text'),
                    icon: Icon(Icons.text_fields),
                  ),
                  ButtonSegment(
                    value: TestimonyType.audio,
                    label: Text('Audio'),
                    icon: Icon(Icons.mic),
                  ),
                  ButtonSegment(
                    value: TestimonyType.video,
                    label: Text('Video'),
                    icon: Icon(Icons.videocam),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TestimonyType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Category
              DropdownButtonFormField<TestimonyCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: TestimonyCategory.values.map((category) {
                  final testimony = TestimonyModel(
                    id: '',
                    userId: '',
                    userName: '',
                    title: '',
                    content: '',
                    category: category,
                    type: TestimonyType.text,
                    status: TestimonyStatus.approved,
                    createdAt: DateTime.now(),
                  );
                  return DropdownMenuItem(
                    value: category,
                    child: Text(testimony.categoryDisplay),
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
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Give your testimony a title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, fieldName: 'Title'),
                maxLength: 100,
              ),
              const SizedBox(height: 16),

              // Content (for all types)
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: _selectedType == TestimonyType.text
                      ? 'Your Testimony *'
                      : 'Description *',
                  hintText: _selectedType == TestimonyType.text
                      ? 'Share how God worked in your life...'
                      : 'Briefly describe your testimony...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
                maxLines: _selectedType == TestimonyType.text ? 10 : 5,
                validator: (value) => Validators.validateRequired(value,
                    fieldName: 'Testimony'),
              ),
              const SizedBox(height: 24),

              // Audio Upload
              if (_selectedType == TestimonyType.audio) ...[
                const Text(
                  'Audio Recording *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickAudioFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _audioFile != null
                        ? 'Audio selected: ${_audioFile!.path.split('/').last}'
                        : 'Choose Audio File',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                if (_audioFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.audiotrack, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Audio file selected',
                            style: TextStyle(color: Colors.green)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _audioFile = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Video Upload
              if (_selectedType == TestimonyType.video) ...[
                const Text(
                  'Video Recording *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickVideoFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                    _videoFile != null
                        ? 'Video selected: ${_videoFile!.path.split('/').last}'
                        : 'Choose Video File (max 100MB)',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                if (_videoFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text('Video file selected',
                            style: TextStyle(color: Colors.green)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _videoFile = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitTestimony,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Testimony'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Note
              Text(
                '* Required fields\n\n'
                'Your testimony will be reviewed by church leaders before being published. '
                'This helps maintain quality and appropriateness of shared testimonies.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
