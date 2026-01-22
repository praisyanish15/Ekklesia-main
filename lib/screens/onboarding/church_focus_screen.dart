import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

enum ChurchFocus {
  prayer,
  newBelievers,
  memberCare,
  youth,
}

class ChurchFocusScreen extends StatefulWidget {
  final String churchId;

  const ChurchFocusScreen({super.key, required this.churchId});

  @override
  State<ChurchFocusScreen> createState() => _ChurchFocusScreenState();
}

class _ChurchFocusScreenState extends State<ChurchFocusScreen> {
  ChurchFocus? _selectedFocus;
  bool _isSaving = false;

  Future<void> _saveFocusAndContinue() async {
    if (_selectedFocus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your church focus'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save church focus to database
      await SupabaseService.client.from('churches').update({
        'primary_focus': _selectedFocus!.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.churchId);

      if (mounted) {
        // Show success and navigate to home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Church setup complete! Welcome to Ekklesia.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to home (replace with your actual home screen route)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Step 2 of 2',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Header
              const Text(
                'What does your church need most right now?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose one focus to get started. You can add more features anytime.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Focus Options
              Expanded(
                child: ListView(
                  children: [
                    _FocusCard(
                      icon: Icons.prayer_times,
                      iconColor: Colors.purple,
                      title: 'Prayer',
                      description: 'Build a culture of prayer and intercession',
                      features: ['Prayer Wall', 'Prayer Requests', 'Answered Prayers'],
                      isSelected: _selectedFocus == ChurchFocus.prayer,
                      onTap: () {
                        setState(() {
                          _selectedFocus = ChurchFocus.prayer;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _FocusCard(
                      icon: Icons.person_add,
                      iconColor: Colors.green,
                      title: 'New Believers',
                      description: 'Disciple and nurture new Christians',
                      features: ['New Believer Path', 'Baptism Track', 'Mentorship'],
                      isSelected: _selectedFocus == ChurchFocus.newBelievers,
                      onTap: () {
                        setState(() {
                          _selectedFocus = ChurchFocus.newBelievers;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _FocusCard(
                      icon: Icons.people,
                      iconColor: Colors.blue,
                      title: 'Member Care',
                      description: 'Connect and care for your congregation',
                      features: ['Check-ins', 'Care Groups', 'Follow-ups'],
                      isSelected: _selectedFocus == ChurchFocus.memberCare,
                      onTap: () {
                        setState(() {
                          _selectedFocus = ChurchFocus.memberCare;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _FocusCard(
                      icon: Icons.trending_up,
                      iconColor: Colors.orange,
                      title: 'Youth',
                      description: 'Engage and grow the next generation',
                      features: ['Youth Path', 'Events', 'Mentorship'],
                      isSelected: _selectedFocus == ChurchFocus.youth,
                      onTap: () {
                        setState(() {
                          _selectedFocus = ChurchFocus.youth;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Continue Button
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveFocusAndContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Complete Setup',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _FocusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? iconColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: iconColor, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features
                  .map(
                    (feature) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? iconColor.withValues(alpha: 0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? iconColor : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
