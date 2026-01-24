import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/church_model.dart';
import '../../models/bank_details_model.dart';
import '../../models/campaign_model.dart';
import '../../services/payment_settings_service.dart';
import '../../services/campaign_service.dart';
import '../../providers/auth_provider.dart';
import 'add_campaign_screen.dart';

class ChurchDonationsScreen extends StatefulWidget {
  final ChurchModel church;

  const ChurchDonationsScreen({
    super.key,
    required this.church,
  });

  @override
  State<ChurchDonationsScreen> createState() => _ChurchDonationsScreenState();
}

class _ChurchDonationsScreenState extends State<ChurchDonationsScreen> {
  final PaymentSettingsService _paymentService = PaymentSettingsService();
  final CampaignService _campaignService = CampaignService();
  List<BankDetails> _bankDetails = [];
  List<CampaignModel> _campaigns = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load bank details and campaigns in parallel
      final results = await Future.wait([
        _paymentService.getChurchBankDetails(widget.church.id),
        _loadCampaigns(),
      ]);

      setState(() {
        _bankDetails = results[0] as List<BankDetails>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCampaigns() async {
    try {
      final campaigns = await _campaignService.getActiveCampaigns(widget.church.id);
      setState(() {
        _campaigns = campaigns;
      });
    } catch (e) {
      // Silently fail if campaigns table doesn't exist yet
      final errorStr = e.toString().toLowerCase();
      if (!errorStr.contains('pgrst205') && !errorStr.contains('schema cache')) {
        debugPrint('Failed to load campaigns: $e');
      }
    }
  }

  bool _isChurchCreator(String? userId) {
    return userId != null && widget.church.createdBy == userId;
  }

  Future<void> _downloadQrCode() async {
    if (widget.church.paymentQrCodeUrl == null) return;

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading QR code...')),
      );

      // Download image
      final response = await Dio().get(
        widget.church.paymentQrCodeUrl!,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: '${widget.church.name}_payment_qr',
      );

      if (result['isSuccess']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR code saved to gallery!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.id;
    final isCreator = _isChurchCreator(currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donate to ${widget.church.name}',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      floatingActionButton: isCreator
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCampaignScreen(
                      churchId: widget.church.id,
                      creatorId: currentUserId!,
                    ),
                  ),
                );
                if (result == true) {
                  _loadCampaigns();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Campaign'),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header message
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.volunteer_activism,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your generosity helps support the ministry and mission of our church',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active Campaigns Section
            if (_campaigns.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.campaign,
                title: 'Active Campaigns',
              ),
              const SizedBox(height: 16),
              ..._campaigns.map((campaign) => _CampaignCard(campaign: campaign)),
              const SizedBox(height: 24),
            ],

            // QR Code Section
            if (widget.church.paymentQrCodeUrl != null) ...[
              _SectionHeader(
                icon: Icons.qr_code_2,
                title: 'Scan QR Code to Pay',
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // QR Code Image
                        Container(
                          width: 250,
                          height: 250,
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

                        // UPI ID if available
                        if (widget.church.upiId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.church.upiId!,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  onPressed: () => _copyToClipboard(
                                    widget.church.upiId!,
                                    'UPI ID',
                                  ),
                                  tooltip: 'Copy UPI ID',
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Download button
                        ElevatedButton.icon(
                          onPressed: _downloadQrCode,
                          icon: const Icon(Icons.download),
                          label: const Text('Download QR Code'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Supported apps
                        Text(
                          'Use with PhonePe, Google Pay, Paytm, BHIM & more',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Bank Details Section
            if (_bankDetails.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.account_balance,
                title: 'Bank Transfer Details',
              ),
              const SizedBox(height: 16),
              ..._bankDetails.map((details) => _BankDetailsCard(
                    bankDetails: details,
                    onCopy: _copyToClipboard,
                  )),
              const SizedBox(height: 32),
            ],

            // Empty state if no payment methods
            if (widget.church.paymentQrCodeUrl == null &&
                _bankDetails.isEmpty &&
                !_isLoading) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No payment methods configured',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Church administrators can set up payment methods in settings',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Loading state
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              ),
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

class _BankDetailsCard extends StatelessWidget {
  final BankDetails bankDetails;
  final Function(String, String) onCopy;

  const _BankDetailsCard({
    required this.bankDetails,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bank name with primary badge
            Row(
              children: [
                Text(
                  bankDetails.bankName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (bankDetails.isPrimary) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Account holder name
            _DetailRow(
              label: 'Account Holder',
              value: bankDetails.accountHolderName,
              onCopy: () => onCopy(
                bankDetails.accountHolderName,
                'Account holder name',
              ),
            ),

            const SizedBox(height: 12),

            // Account number
            _DetailRow(
              label: 'Account Number',
              value: bankDetails.accountNumber,
              onCopy: () => onCopy(
                bankDetails.accountNumber,
                'Account number',
              ),
            ),

            const SizedBox(height: 12),

            // IFSC code
            _DetailRow(
              label: 'IFSC Code',
              value: bankDetails.ifscCode,
              onCopy: () => onCopy(bankDetails.ifscCode, 'IFSC code'),
            ),

            if (bankDetails.branchName != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Branch',
                value: bankDetails.branchName!,
                showCopy: false,
              ),
            ],

            if (bankDetails.accountType != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Account Type',
                value: bankDetails.accountType!.toUpperCase(),
                showCopy: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final bool showCopy;

  const _DetailRow({
    required this.label,
    required this.value,
    this.onCopy,
    this.showCopy = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (showCopy && onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            onPressed: onCopy,
            tooltip: 'Copy',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;

  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\u20B9', decimalDigits: 0);

    final daysLeft = campaign.endDate.difference(DateTime.now()).inDays;
    final progress = campaign.progressPercentage.clamp(0, 100);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    campaign.title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: daysLeft > 7
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    daysLeft > 0 ? '$daysLeft days left' : 'Ending today',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: daysLeft > 7 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              campaign.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),

            const SizedBox(height: 12),

            // Amount info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raised',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      currencyFormat.format(campaign.currentAmount),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Goal',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      currencyFormat.format(campaign.targetAmount),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date range
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 6),
                Text(
                  '${dateFormat.format(campaign.startDate)} - ${dateFormat.format(campaign.endDate)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
