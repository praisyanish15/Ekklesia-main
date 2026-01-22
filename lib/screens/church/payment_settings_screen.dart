import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../models/church_model.dart';
import '../../models/bank_details_model.dart';
import '../../services/payment_settings_service.dart';

class PaymentSettingsScreen extends StatefulWidget {
  final ChurchModel church;

  const PaymentSettingsScreen({
    super.key,
    required this.church,
  });

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final PaymentSettingsService _paymentService = PaymentSettingsService();
  final ImagePicker _imagePicker = ImagePicker();

  List<BankDetails> _bankDetails = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String _errorMessage = '';

  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _razorpayKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _upiIdController.text = widget.church.upiId ?? '';
    _razorpayKeyController.text = widget.church.razorpayKeyId ?? '';
    _loadBankDetails();
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _razorpayKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadBankDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final details = await _paymentService.getChurchBankDetails(widget.church.id);
      setState(() {
        _bankDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadQrCode() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final bytes = await image.readAsBytes();
      final qrUrl = await _paymentService.uploadQrCodeImage(
        churchId: widget.church.id,
        fileBytes: bytes,
      );

      await _paymentService.updatePaymentQrCode(
        churchId: widget.church.id,
        qrCodeUrl: qrUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh parent screen
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateUpiId() async {
    try {
      await _paymentService.updateUpiId(
        churchId: widget.church.id,
        upiId: _upiIdController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('UPI ID updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateRazorpayKey() async {
    try {
      await _paymentService.updateRazorpayKey(
        churchId: widget.church.id,
        razorpayKeyId: _razorpayKeyController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Razorpay key updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddBankDetailsDialog() {
    final formKey = GlobalKey<FormState>();
    final bankNameController = TextEditingController();
    final accountHolderController = TextEditingController();
    final accountNumberController = TextEditingController();
    final ifscCodeController = TextEditingController();
    final branchNameController = TextEditingController();
    String accountType = 'savings';
    bool isPrimary = _bankDetails.isEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Bank Details',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: bankNameController,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: accountHolderController,
                  decoration: const InputDecoration(labelText: 'Account Holder Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: accountNumberController,
                  decoration: const InputDecoration(labelText: 'Account Number'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: ifscCodeController,
                  decoration: const InputDecoration(labelText: 'IFSC Code'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: branchNameController,
                  decoration: const InputDecoration(labelText: 'Branch Name (Optional)'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: accountType,
                  decoration: const InputDecoration(labelText: 'Account Type'),
                  items: const [
                    DropdownMenuItem(value: 'savings', child: Text('Savings')),
                    DropdownMenuItem(value: 'current', child: Text('Current')),
                  ],
                  onChanged: (value) => accountType = value!,
                ),
                if (_bankDetails.isNotEmpty)
                  StatefulBuilder(
                    builder: (context, setState) => CheckboxListTile(
                      title: const Text('Set as primary account'),
                      value: isPrimary,
                      onChanged: (value) => setState(() => isPrimary = value!),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _paymentService.addBankDetails(
                    churchId: widget.church.id,
                    bankName: bankNameController.text,
                    accountHolderName: accountHolderController.text,
                    accountNumber: accountNumberController.text,
                    ifscCode: ifscCodeController.text.toUpperCase(),
                    branchName: branchNameController.text.isEmpty
                        ? null
                        : branchNameController.text,
                    accountType: accountType,
                    isPrimary: isPrimary,
                  );

                  Navigator.of(context).pop();
                  _loadBankDetails();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bank details added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBankDetails(String bankDetailsId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bank Details'),
        content: const Text('Are you sure you want to delete these bank details?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _paymentService.deleteBankDetails(bankDetailsId);
        _loadBankDetails();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bank details deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Settings',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Code Section
            _SectionHeader(
              icon: Icons.qr_code_2,
              title: 'Payment QR Code',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    if (widget.church.paymentQrCodeUrl != null) ...[
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.church.paymentQrCodeUrl!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _uploadQrCode,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      label: Text(
                        widget.church.paymentQrCodeUrl == null
                            ? 'Upload QR Code'
                            : 'Replace QR Code',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload a payment QR code for UPI payments',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // UPI ID Section
            _SectionHeader(
              icon: Icons.account_balance_wallet,
              title: 'UPI ID',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _upiIdController,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID',
                        hintText: 'yourchurch@upi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateUpiId,
                        child: const Text('Update UPI ID'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Razorpay Key Section
            _SectionHeader(
              icon: Icons.key,
              title: 'Razorpay Integration',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _razorpayKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Razorpay Key ID',
                        hintText: 'rzp_live_xxxxxxxxxx',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateRazorpayKey,
                        child: const Text('Update Razorpay Key'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Bank Details Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionHeader(
                  icon: Icons.account_balance,
                  title: 'Bank Accounts',
                ),
                ElevatedButton.icon(
                  onPressed: _showAddBankDetailsDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Bank'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_bankDetails.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 48,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bank accounts added',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._bankDetails.map((details) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  details.bankName,
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (details.isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PRIMARY',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: theme.brightness == Brightness.light
                                          ? const Color(0xFF0B1929)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteBankDetails(details.id),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Account Holder: ${details.accountHolderName}'),
                          Text('Account Number: ${details.maskedAccountNumber}'),
                          Text('IFSC: ${details.ifscCode}'),
                          if (details.branchName != null)
                            Text('Branch: ${details.branchName}'),
                          if (details.accountType != null)
                            Text('Type: ${details.accountType!.toUpperCase()}'),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
