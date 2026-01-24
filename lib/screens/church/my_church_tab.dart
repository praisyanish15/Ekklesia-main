import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/church_model.dart';
import '../../models/prayer_request_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/church_service.dart';
import '../../services/prayer_service.dart';
import '../prayer/prayer_wall_screen.dart';
import '../prayer/submit_prayer_screen.dart';
import 'join_church_screen.dart';
import 'church_info_screen.dart';
import 'songs_list_screen.dart';
import 'church_members_screen.dart';

class MyChurchTab extends StatefulWidget {
  const MyChurchTab({super.key});

  @override
  State<MyChurchTab> createState() => _MyChurchTabState();
}

class _MyChurchTabState extends State<MyChurchTab> {
  final ChurchService _churchService = ChurchService();
  final PrayerService _prayerService = PrayerService();

  ChurchModel? _church;
  List<ChurchModel> _createdChurches = [];
  List<PrayerRequestModel> _recentPrayers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _lastKnownChurchId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when user's churchId changes
    final authProvider = context.watch<AuthProvider>();
    final currentChurchId = authProvider.currentUser?.churchId;

    // Reload if churchId changed (user joined or left a church)
    if (currentChurchId != _lastKnownChurchId && !_isLoading) {
      _lastKnownChurchId = currentChurchId;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load churches created by user
      List<ChurchModel> createdChurches = [];
      if (user != null) {
        try {
          createdChurches = await _churchService.getChurchesCreatedByUser(user.id);
        } catch (e) {
          // Failed to load created churches, continue
        }
      }

      // Load user's joined church info
      ChurchModel? church;
      List<PrayerRequestModel> prayers = [];

      if (user?.churchId != null) {
        church = await _churchService.getChurchById(user!.churchId!);

        // Load recent public prayers
        try {
          prayers = await _prayerService.getPublicPrayers(
            churchId: user.churchId!,
            limit: 5,
          );
        } catch (e) {
          // Prayer loading failed, but continue with church info
        }
      }

      if (mounted) {
        setState(() {
          _church = church;
          _createdChurches = createdChurches;
          _recentPrayers = prayers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // User hasn't joined a church and hasn't created any
    if ((user?.churchId == null || _church == null) && _createdChurches.isEmpty) {
      return _NoChurchView(onRefresh: _loadData);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Churches You Created Section
            if (_createdChurches.isNotEmpty) ...[
              _CreatedChurchesSection(
                churches: _createdChurches,
                currentChurchId: user?.churchId,
                onChurchTap: (church) {
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
                onShareCodeTap: (church) => _showShareCodeDialogForChurch(context, church),
              ),
              const SizedBox(height: 24),
            ],

            // Current Church Section (if user has joined one)
            if (_church != null) ...[
              // Church Header Card
              _ChurchHeaderCard(church: _church!),
              const SizedBox(height: 24),

              // Quick Actions
              _QuickActionsSection(
                church: _church!,
                user: user!,
                onPrayerWallTap: () => _navigateToPrayerWall(context),
                onSubmitPrayerTap: () => _navigateToSubmitPrayer(context),
                onChurchInfoTap: () => _navigateToChurchInfo(context),
                onWorshipTap: () => _navigateToWorship(context),
                onMembersTap: () => _navigateToMembers(context),
                // Only show share code option for church creator
                onShareCodeTap: _church!.createdBy == user!.id
                    ? () => _showShareCodeDialog(context)
                    : null,
              ),
              const SizedBox(height: 24),

              // Recent Prayer Requests
              _PrayerRequestsSection(
                prayers: _recentPrayers,
                onSeeAllTap: () => _navigateToPrayerWall(context),
                onPrayerTap: (prayer) => _showPrayerDetail(context, prayer),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showShareCodeDialogForChurch(BuildContext context, ChurchModel church) {
    final referralCode = church.referralCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.share, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(church.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share this code to invite people to join:',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Text(
                referralCode,
                style: GoogleFonts.robotoMono(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.orange[800],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral code copied to clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Share.share(
                'Join ${church.name} on Ekklesia! Use referral code: $referralCode',
                subject: 'Join our church on Ekklesia',
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPrayerWall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrayerWallScreen(),
      ),
    );
  }

  void _navigateToSubmitPrayer(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubmitPrayerScreen(),
      ),
    );

    if (result == true) {
      _loadData(); // Refresh after submitting prayer
    }
  }

  void _navigateToChurchInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChurchInfoScreen(church: _church!),
      ),
    );
  }

  void _navigateToWorship(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongsListScreen(
          churchId: _church!.id,
          churchName: _church!.name,
        ),
      ),
    );
  }

  void _navigateToMembers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChurchMembersScreen(
          churchId: _church!.id,
          churchName: _church!.name,
        ),
      ),
    );
  }

  void _showShareCodeDialog(BuildContext context) {
    final referralCode = _church!.referralCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.share, color: Colors.orange),
            const SizedBox(width: 8),
            const Expanded(child: Text('Church Referral Code')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share this code with others to invite them to join ${_church!.name}:',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Text(
                referralCode,
                style: GoogleFonts.robotoMono(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.orange[800],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Referral code copied to clipboard!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Share.share(
                'Join ${_church!.name} on Ekklesia! Use referral code: $referralCode',
                subject: 'Join our church on Ekklesia',
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrayerDetail(BuildContext context, PrayerRequestModel prayer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PrayerDetailSheet(
        prayer: prayer,
        onPray: () async {
          await _prayerService.incrementPrayerCount(prayer.id);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for praying!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}

class _NoChurchView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _NoChurchView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.church,
              size: 100,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Church Joined',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Join a church to see updates, prayer requests, and connect with your community',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinChurchScreen(),
                  ),
                );
                if (result == true) {
                  onRefresh();
                }
              },
              icon: const Icon(Icons.group_add),
              label: const Text('Join Church'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                await authProvider.refreshProfile();
                onRefresh(); // Also reload the tab data
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatedChurchesSection extends StatelessWidget {
  final List<ChurchModel> churches;
  final String? currentChurchId;
  final Function(ChurchModel) onChurchTap;
  final Function(ChurchModel) onShareCodeTap;

  const _CreatedChurchesSection({
    required this.churches,
    required this.currentChurchId,
    required this.onChurchTap,
    required this.onShareCodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_business, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Churches You Created',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...churches.map((church) => _CreatedChurchCard(
              church: church,
              isCurrentChurch: church.id == currentChurchId,
              onTap: () => onChurchTap(church),
              onShareCodeTap: () => onShareCodeTap(church),
            )),
      ],
    );
  }
}

class _CreatedChurchCard extends StatelessWidget {
  final ChurchModel church;
  final bool isCurrentChurch;
  final VoidCallback onTap;
  final VoidCallback onShareCodeTap;

  const _CreatedChurchCard({
    required this.church,
    required this.isCurrentChurch,
    required this.onTap,
    required this.onShareCodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentChurch
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Church Photo
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: church.photoUrl != null
                    ? NetworkImage(church.photoUrl!)
                    : null,
                child: church.photoUrl == null
                    ? Icon(
                        Icons.church,
                        size: 28,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Church Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            church.name,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentChurch)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'JOINED',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            church.city != null
                                ? '${church.area}, ${church.city}'
                                : church.area,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Share Code Button
              IconButton(
                onPressed: onShareCodeTap,
                icon: const Icon(Icons.share),
                color: Colors.orange,
                tooltip: 'Share Referral Code',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChurchHeaderCard extends StatelessWidget {
  final ChurchModel church;

  const _ChurchHeaderCard({required this.church});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Church Photo/Icon
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: church.photoUrl != null
                  ? NetworkImage(church.photoUrl!)
                  : null,
              child: church.photoUrl == null
                  ? Icon(
                      Icons.church,
                      size: 50,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Church Name
            Text(
              church.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  church.city != null
                      ? '${church.area}, ${church.city}'
                      : church.area,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),

            // Pastor Name
            if (church.pastorName != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pastor ${church.pastorName}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final ChurchModel church;
  final UserModel user;
  final VoidCallback onPrayerWallTap;
  final VoidCallback onSubmitPrayerTap;
  final VoidCallback onChurchInfoTap;
  final VoidCallback onWorshipTap;
  final VoidCallback onMembersTap;
  final VoidCallback? onShareCodeTap; // Only for creators

  const _QuickActionsSection({
    required this.church,
    required this.user,
    required this.onPrayerWallTap,
    required this.onSubmitPrayerTap,
    required this.onChurchInfoTap,
    required this.onWorshipTap,
    required this.onMembersTap,
    this.onShareCodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // First row: Worship Songs and Members
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.music_note,
                label: 'Worship Songs',
                color: Colors.deepPurple,
                onTap: onWorshipTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.people,
                label: 'Members',
                color: Colors.indigo,
                onTap: onMembersTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row: Prayer Wall and Submit Prayer
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.volunteer_activism,
                label: 'Prayer Wall',
                color: Colors.purple,
                onTap: onPrayerWallTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle_outline,
                label: 'Submit Prayer',
                color: Colors.blue,
                onTap: onSubmitPrayerTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Third row: Church Info and Contact/Share Code
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.info_outline,
                label: 'Church Info',
                color: Colors.teal,
                onTap: onChurchInfoTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: onShareCodeTap != null
                  ? _QuickActionCard(
                      icon: Icons.share,
                      label: 'Share Code',
                      color: Colors.orange,
                      onTap: onShareCodeTap!,
                    )
                  : _QuickActionCard(
                      icon: Icons.phone,
                      label: 'Contact',
                      color: Colors.green,
                      onTap: () {
                        if (church.phoneNumber != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Phone: ${church.phoneNumber}'),
                              action: SnackBarAction(
                                label: 'Copy',
                                onPressed: () {
                                  // Copy to clipboard
                                },
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No phone number available'),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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

class _PrayerRequestsSection extends StatelessWidget {
  final List<PrayerRequestModel> prayers;
  final VoidCallback onSeeAllTap;
  final Function(PrayerRequestModel) onPrayerTap;

  const _PrayerRequestsSection({
    required this.prayers,
    required this.onSeeAllTap,
    required this.onPrayerTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prayer Requests',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onSeeAllTap,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (prayers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      size: 48,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No prayer requests yet',
                      style: GoogleFonts.inter(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...prayers.map((prayer) => _PrayerCard(
                prayer: prayer,
                onTap: () => onPrayerTap(prayer),
              )),
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerRequestModel prayer;
  final VoidCallback onTap;

  const _PrayerCard({required this.prayer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: prayer.userPhotoUrl != null
                        ? NetworkImage(prayer.userPhotoUrl!)
                        : null,
                    child: prayer.userPhotoUrl == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayer.userName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDate(prayer.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (prayer.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'URGENT',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                prayer.title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                prayer.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${prayer.prayerCount} prayers',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _PrayerDetailSheet extends StatelessWidget {
  final PrayerRequestModel prayer;
  final VoidCallback onPray;

  const _PrayerDetailSheet({
    required this.prayer,
    required this.onPray,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: prayer.userPhotoUrl != null
                            ? NetworkImage(prayer.userPhotoUrl!)
                            : null,
                        child: prayer.userPhotoUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prayer.userName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatFullDate(prayer.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (prayer.isUrgent)
                        Chip(
                          label: const Text('URGENT'),
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    prayer.title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    prayer.description,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category chip
                  Chip(
                    label: Text(prayer.category.name.toUpperCase()),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                  const SizedBox(height: 24),

                  // Pray button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPray,
                      icon: const Icon(Icons.favorite),
                      label: Text('I Prayed (${prayer.prayerCount})'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
