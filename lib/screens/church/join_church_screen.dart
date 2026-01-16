import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/church_service.dart';
import '../../models/church_model.dart';
import 'face_verification_screen.dart';

class JoinChurchScreen extends StatefulWidget {
  const JoinChurchScreen({super.key});

  @override
  State<JoinChurchScreen> createState() => _JoinChurchScreenState();
}

class _JoinChurchScreenState extends State<JoinChurchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _churchService = ChurchService();
  final _referralCodeController = TextEditingController();

  bool _isLoading = false;
  ChurchModel? _foundChurch;

  @override
  void dispose() {
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _searchChurch() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _foundChurch = null;
      });

      try {
        final church = await _churchService.getChurchByReferralCode(
          _referralCodeController.text.trim(),
        );

        setState(() {
          _foundChurch = church;
        });

        if (church == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid referral code. Please check and try again.'),
              backgroundColor: Colors.red,
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
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _joinChurch() async {
    if (_foundChurch == null) return;

    // First, verify face
    final faceImagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const FaceVerificationScreen(),
      ),
    );

    if (faceImagePath == null) {
      // User cancelled face verification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Face verification is required to join a church'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // TODO: Upload face image to Supabase storage
      // For now, we'll just proceed with joining

      await _churchService.joinChurchWithReferralCode(
        referralCode: _referralCodeController.text.trim(),
        userId: authProvider.currentUser!.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined ${_foundChurch!.name}! Your identity has been verified.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Church'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                      Expanded(
                        child: Text(
                          'Enter the 6-character referral code provided by your church.',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Icon
              Icon(
                Icons.church,
                size: 80,
                color: Colors.blue[300],
              ),
              const SizedBox(height: 32),

              // Referral Code Input
              TextFormField(
                controller: _referralCodeController,
                decoration: InputDecoration(
                  labelText: 'Referral Code',
                  hintText: 'ABC123',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.tag),
                  counterText: '',
                  suffixIcon: _referralCodeController.text.length == 6
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                ],
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a referral code';
                  }
                  if (value.trim().length != 6) {
                    return 'Referral code must be 6 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    if (value.length != 6) {
                      _foundChurch = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              // Search Button
              if (_foundChurch == null)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchChurch,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isLoading ? 'Searching...' : 'Find Church'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

              // Church Details Card
              if (_foundChurch != null) ...[
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue[100],
                              child: _foundChurch!.photoUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _foundChurch!.photoUrl!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(Icons.church,
                                      size: 35, color: Colors.blue[700]),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _foundChurch!.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _foundChurch!.area,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        if (_foundChurch!.pastorName != null)
                          _DetailRow(
                            icon: Icons.person,
                            label: 'Pastor',
                            value: _foundChurch!.pastorName!,
                          ),
                        if (_foundChurch!.city != null)
                          _DetailRow(
                            icon: Icons.location_city,
                            label: 'City',
                            value: _foundChurch!.city!,
                          ),
                        if (_foundChurch!.phoneNumber != null)
                          _DetailRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: _foundChurch!.phoneNumber!,
                          ),
                        if (_foundChurch!.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'About',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_foundChurch!.description!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Join Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _joinChurch,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.group_add),
                  label: Text(_isLoading ? 'Joining...' : 'Join This Church'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
