import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/church_service.dart';
import '../../utils/validators.dart';
import 'church_focus_screen.dart';

class PastorSetupScreen extends StatefulWidget {
  const PastorSetupScreen({super.key});

  @override
  State<PastorSetupScreen> createState() => _PastorSetupScreenState();
}

class _PastorSetupScreenState extends State<PastorSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _churchService = ChurchService();

  final _churchNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _pastorNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _churchNameController.dispose();
    _cityController.dispose();
    _pastorNameController.dispose();
    _whatsappController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _setupChurch() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.currentUser == null) {
          throw Exception('Please login first');
        }

        final church = await _churchService.createChurch(
          name: _churchNameController.text.trim(),
          pastorName: _pastorNameController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim(),
          area: _cityController.text.trim(),
          phoneNumber: _whatsappController.text.trim(),
          createdBy: authProvider.currentUser!.id,
        );

        if (mounted) {
          // Navigate to church focus selection
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChurchFocusScreen(churchId: church.id),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Set Up Your Church',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Takes just 2 minutes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Progress Indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Step 1 of 2',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Church Name
              TextFormField(
                controller: _churchNameController,
                decoration: InputDecoration(
                  labelText: 'Church Name *',
                  hintText: 'Grace Community Church',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.church),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, fieldName: 'Church name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City *',
                  hintText: 'Mumbai',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_city),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, fieldName: 'City'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Pastor/Admin Name
              TextFormField(
                controller: _pastorNameController,
                decoration: InputDecoration(
                  labelText: 'Pastor / Admin Name *',
                  hintText: 'Pastor John',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) =>
                    Validators.validateRequired(value, fieldName: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // License Number
              TextFormField(
                controller: _licenseNumberController,
                decoration: InputDecoration(
                  labelText: 'Church License Number *',
                  hintText: 'CH12345678',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.verified),
                  helperText: '8-20 alphanumeric characters',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'License number is required';
                  }
                  if (!_churchService.isValidLicenseNumber(value)) {
                    return 'Must be 8-20 alphanumeric characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),

              // WhatsApp Number
              TextFormField(
                controller: _whatsappController,
                decoration: InputDecoration(
                  labelText: 'WhatsApp Number *',
                  hintText: '+91 98765 43210',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) =>
                    Validators.validatePhone(value),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'You will be automatically set as the Super Admin of this church.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _setupChurch,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Set Up My Church',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Privacy Note
              Text(
                'By continuing, you agree to provide accurate church information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
