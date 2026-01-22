import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../models/campaign_model.dart';
import '../../services/payment_service.dart';
import 'package:intl/intl.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  late PaymentService _paymentService;
  List<CampaignModel> _campaigns = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
    );
    _loadCampaigns();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _loadCampaigns() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Fetch campaigns from backend
    // For now, using empty list
    setState(() {
      _campaigns = [];
      _isLoading = false;
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    // Record the donation
    // await _paymentService.recordDonation(...);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Thank you for your donation.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadCampaigns();
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDonateDialog(CampaignModel campaign) {
    showDialog(
      context: context,
      builder: (context) => _DonateDialog(
        campaign: campaign,
        onDonate: (amount) => _processDonation(campaign, amount),
      ),
    );
  }

  void _processDonation(CampaignModel campaign, double amount) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to make a donation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _paymentService.startPayment(
      amount: amount,
      campaignId: campaign.id,
      userId: user.id,
      name: user.name,
      email: user.email,
      phone: user.phoneNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Column(
            children: [
              const Icon(
                Icons.volunteer_activism,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                'Support Our Community',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Your donations help those in need',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // Campaigns List
        Expanded(
          child: _campaigns.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No active campaigns',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = _campaigns[index];
                    return _CampaignCard(
                      campaign: campaign,
                      onDonate: () => _showDonateDialog(campaign),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onDonate;

  const _CampaignCard({
    required this.campaign,
    required this.onDonate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Image
          if (campaign.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                campaign.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campaign Title
                Text(
                  campaign.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Campaign Description
                Text(
                  campaign.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: campaign.progressPercentage / 100,
                      backgroundColor: Colors.grey[300],
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${NumberFormat('#,##,###').format(campaign.currentAmount)} raised',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(campaign.targetAmount)} goal',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // End Date
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Ends: ${DateFormat('MMM d, y').format(campaign.endDate)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Donate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: campaign.status == CampaignStatus.active
                        ? onDonate
                        : null,
                    icon: const Icon(Icons.favorite),
                    label: const Text('Donate Now'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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

class _DonateDialog extends StatefulWidget {
  final CampaignModel campaign;
  final Function(double) onDonate;

  const _DonateDialog({
    required this.campaign,
    required this.onDonate,
  });

  @override
  State<_DonateDialog> createState() => _DonateDialogState();
}

class _DonateDialogState extends State<_DonateDialog> {
  final TextEditingController _amountController = TextEditingController();
  final List<double> _quickAmounts = [100, 500, 1000, 5000];
  double? _selectedAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  void _processDonation() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onDonate(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Donate to ${widget.campaign.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select or enter amount:'),
            const SizedBox(height: 12),

            // Quick Amount Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text('₹${NumberFormat('#,###').format(amount)}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) _selectAmount(amount);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom Amount Input
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Custom Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _selectedAmount = double.tryParse(value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _processDonation,
          child: const Text('Proceed to Payment'),
        ),
      ],
    );
  }
}
