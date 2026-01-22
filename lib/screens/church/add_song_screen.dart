import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../../services/song_service.dart';

class AddSongScreen extends StatefulWidget {
  final String churchId;

  const AddSongScreen({
    super.key,
    required this.churchId,
  });

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final SongService _songService = SongService();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _chordsController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedLanguage = 'english';
  String? _selectedCategory;
  double? _latitude;
  double? _longitude;
  bool _isProcessing = false;
  bool _isSaving = false;

  final List<String> _languages = ['english', 'hindi'];
  final List<String> _categories = ['Worship', 'Praise', 'Hymn', 'Gospel', 'Contemporary'];

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _chordsController.dispose();
    _keyController.dispose();
    _linkController.dispose();
    _lyricsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndExtractText() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image == null) return;

      setState(() => _isProcessing = true);

      // Process image with ML Kit Text Recognition
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Extract text
      String extractedText = recognizedText.text;

      if (extractedText.isNotEmpty) {
        setState(() {
          _lyricsController.text = extractedText;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully extracted ${extractedText.split('\n').length} lines'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No text found in the image'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      await textRecognizer.close();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error extracting text: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Song',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text('Are you sure you want to add this song?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Add Song'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      await _songService.addSong(
        churchId: widget.churchId,
        title: _titleController.text.trim(),
        artist: _artistController.text.trim().isEmpty ? null : _artistController.text.trim(),
        lyrics: _lyricsController.text.trim(),
        category: _selectedCategory,
        chords: _chordsController.text.trim().isEmpty ? null : _chordsController.text.trim(),
        key: _keyController.text.trim().isEmpty ? null : _keyController.text.trim(),
        link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        language: _selectedLanguage,
        latitude: _latitude,
        longitude: _longitude,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text('Are you sure you want to cancel? All entered data will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADD SONG',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Song Title *',
                  hintText: 'Enter song title',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.music_note),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter song title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Artist
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist',
                  hintText: 'Enter artist name (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),

              // Chords
              TextFormField(
                controller: _chordsController,
                decoration: const InputDecoration(
                  labelText: 'Chords',
                  hintText: 'e.g., C, G, Am, F',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.piano),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Key
              TextFormField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'Musical Key',
                  hintText: 'e.g., C, G, D major',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.music_note_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Link
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'YouTube/External Link',
                  hintText: 'https://youtube.com/...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Language
              Text(
                'Language *',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: _languages.map((lang) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Text(lang.toUpperCase()),
                      selected: _selectedLanguage == lang,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedLanguage = lang);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where was this song recorded/performed?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 24),

              // Lyrics Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Song Lyrics *',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _pickImageAndExtractText,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt, size: 18),
                    label: Text(_isProcessing ? 'Processing...' : 'Scan Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lyrics Text Field
              TextFormField(
                controller: _lyricsController,
                decoration: const InputDecoration(
                  hintText: 'Enter song lyrics here or scan from image above',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 15,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter lyrics or scan from image';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _confirmCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.red.shade400),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSong,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'ADD SONG',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
