import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_helper.dart';
import '../../utils/validators.dart';
import '../../constants/app_constants.dart';
import '../../services/church_service.dart';
import '../../models/church_model.dart';
import '../church/church_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ChurchService _churchService = ChurchService();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  File? _selectedImage;
  bool _isEditing = false;
  List<ChurchModel> _createdChurches = [];
  bool _isLoadingChurches = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _selectedGender = user?.gender;
    _loadCreatedChurches();
  }

  Future<void> _loadCreatedChurches() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    setState(() => _isLoadingChurches = true);

    try {
      final churches = await _churchService.getChurchesCreatedByUser(user.id);
      if (mounted) {
        setState(() {
          _createdChurches = churches;
          _isLoadingChurches = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingChurches = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Capture context-dependent references before async operations
    final authProvider = context.read<AuthProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final image = await showDialog<File>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Select Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  final navigator = Navigator.of(dialogContext);
                  final img = await ImageHelper.pickImageFromGallery();
                  navigator.pop(img);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  final navigator = Navigator.of(dialogContext);
                  final img = await ImageHelper.pickImageFromCamera();
                  navigator.pop(img);
                },
              ),
            ],
          ),
        ),
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        // Upload immediately
        final success = await authProvider.uploadProfilePhoto(image);

        if (success && mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (authProvider.errorMessage != null && mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        age: _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text)
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        gender: _selectedGender,
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      if (success && mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (authProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('No user found'));
          }

          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Photo
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (user.photoUrl != null
                                    ? NetworkImage(user.photoUrl!)
                                    : null)
                                as ImageProvider?,
                        child: user.photoUrl == null && _selectedImage == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    enabled: _isEditing,
                    validator: (value) =>
                        Validators.validateRequired(value, fieldName: 'Name'),
                  ),
                  const SizedBox(height: 16),

                  // Email Field (Read-only)
                  TextFormField(
                    initialValue: user.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // Age Field
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: _isEditing,
                    validator: Validators.validateAge,
                  ),
                  const SizedBox(height: 16),

                  // Gender Field
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: AppConstants.genderOptions
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: _isEditing
                        ? (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 16),

                  // Address Field
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isEditing)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _nameController.text = user.name;
                                _ageController.text =
                                    user.age?.toString() ?? '';
                                _addressController.text = user.address ?? '';
                                _phoneController.text = user.phoneNumber ?? '';
                                _selectedGender = user.gender;
                                _selectedImage = null;
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),

                  // Churches Created By You Section
                  if (!_isEditing) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Churches Created By You',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingChurches)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_createdChurches.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.church_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'You haven\'t created any churches yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/create-church');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create Church'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _createdChurches.length,
                        itemBuilder: (context, index) {
                          final church = _createdChurches[index];
                          return _CreatedChurchCard(
                            church: church,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChurchInfoScreen(
                                    church: church,
                                    isAdmin: true,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CreatedChurchCard extends StatelessWidget {
  final ChurchModel church;
  final VoidCallback onTap;

  const _CreatedChurchCard({
    required this.church,
    required this.onTap,
  });

  Future<void> _copyReferralCode(BuildContext context) async {
    // Copy just the referral code
    await Clipboard.setData(ClipboardData(text: church.referralCode));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Referral code "${church.referralCode}" copied!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        children: [
          // Church Info Header
          ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: church.photoUrl != null
                  ? NetworkImage(church.photoUrl!)
                  : null,
              child: church.photoUrl == null
                  ? const Icon(Icons.church, size: 28)
                  : null,
            ),
            title: Text(
              church.name,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              church.area,
              style: GoogleFonts.inter(fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: onTap,
            ),
            onTap: onTap,
          ),

          const Divider(height: 1),

          // Church Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Pastor Name
                if (church.pastorName != null)
                  _DetailRow(
                    icon: Icons.person,
                    label: 'Pastor',
                    value: church.pastorName!,
                  ),

                // Members count or location
                if (church.city != null)
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: '${church.city}${church.state != null ? ', ${church.state}' : ''}',
                  ),

                const SizedBox(height: 12),

                // Referral Code Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Referral Code',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              church.referralCode,
                              style: GoogleFonts.robotoMono(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyReferralCode(context),
                            icon: const Icon(Icons.copy, size: 20),
                            tooltip: 'Copy code',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share this code to invite members to your church',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
