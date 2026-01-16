import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class FaceVerificationScreen extends StatefulWidget {
  const FaceVerificationScreen({super.key});

  @override
  State<FaceVerificationScreen> createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _capturedImage;
  bool _isProcessing = false;
  bool _isFaceDetected = false;
  String _message = '';

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      setState(() {
        _isProcessing = true;
        _message = 'Detecting face...';
      });

      // Verify face using ML Kit
      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableLandmarks: true,
          enableContours: true,
          enableClassification: true,
          minFaceSize: 0.15,
        ),
      );

      final List<Face> faces = await faceDetector.processImage(inputImage);

      await faceDetector.close();

      if (faces.isEmpty) {
        setState(() {
          _isProcessing = false;
          _isFaceDetected = false;
          _message = 'No face detected. Please try again with better lighting.';
          _capturedImage = null;
        });
        return;
      }

      if (faces.length > 1) {
        setState(() {
          _isProcessing = false;
          _isFaceDetected = false;
          _message = 'Multiple faces detected. Please ensure only you are in the frame.';
          _capturedImage = null;
        });
        return;
      }

      // Check if face is real (basic liveness check)
      final face = faces.first;

      // Check if eyes are open (basic liveness indicator)
      final leftEyeOpen = face.leftEyeOpenProbability;
      final rightEyeOpen = face.rightEyeOpenProbability;

      if (leftEyeOpen != null && rightEyeOpen != null) {
        if (leftEyeOpen < 0.5 || rightEyeOpen < 0.5) {
          setState(() {
            _isProcessing = false;
            _isFaceDetected = false;
            _message = 'Please open your eyes and look at the camera.';
            _capturedImage = null;
          });
          return;
        }
      }

      // Face detected successfully
      setState(() {
        _capturedImage = image;
        _isFaceDetected = true;
        _isProcessing = false;
        _message = 'Face verified successfully!';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isFaceDetected = false;
        _message = 'Error: ${e.toString()}';
        _capturedImage = null;
      });
    }
  }

  void _confirmAndProceed() {
    if (_capturedImage != null && _isFaceDetected) {
      // Return the image path to the calling screen
      Navigator.of(context).pop(_capturedImage!.path);
    }
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
      _isFaceDetected = false;
      _message = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FACE VERIFICATION',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Info Card
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Take a live photo to verify your identity. Ensure good lighting and look directly at the camera.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Photo preview or placeholder
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isFaceDetected
                      ? Colors.green
                      : theme.colorScheme.primary.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: _capturedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Image.file(
                        File(_capturedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.face,
                          size: 100,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No photo captured',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            // Status message
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isFaceDetected
                      ? Colors.green.withOpacity(0.1)
                      : (_message.contains('Error') || _message.contains('No face'))
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isFaceDetected
                        ? Colors.green
                        : (_message.contains('Error') || _message.contains('No face'))
                            ? Colors.red
                            : Colors.blue,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isFaceDetected
                          ? Icons.check_circle
                          : (_message.contains('Error') || _message.contains('No face'))
                              ? Icons.error
                              : Icons.info,
                      color: _isFaceDetected
                          ? Colors.green
                          : (_message.contains('Error') || _message.contains('No face'))
                              ? Colors.red
                              : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message,
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Action buttons
            if (_capturedImage == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _captureImage,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera_alt, size: 24),
                  label: Text(
                    _isProcessing ? 'Processing...' : 'Capture Photo',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isFaceDetected ? _confirmAndProceed : null,
                      icon: const Icon(Icons.check, size: 24),
                      label: Text(
                        'Confirm & Continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.refresh, size: 24),
                      label: Text(
                        'Retake Photo',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Guidelines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo Guidelines:',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _GuidelineItem(
                      icon: Icons.light_mode,
                      text: 'Ensure good lighting on your face',
                    ),
                    _GuidelineItem(
                      icon: Icons.face,
                      text: 'Look directly at the camera',
                    ),
                    _GuidelineItem(
                      icon: Icons.remove_red_eye,
                      text: 'Keep your eyes open',
                    ),
                    _GuidelineItem(
                      icon: Icons.person,
                      text: 'Only your face should be visible',
                    ),
                    _GuidelineItem(
                      icon: Icons.camera,
                      text: 'Hold the camera steady',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuidelineItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
