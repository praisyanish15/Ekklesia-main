import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/church_model.dart';
import '../../widgets/church_header.dart';
import 'church_members_screen.dart';
import 'sermons_list_screen.dart';
import 'songs_list_screen.dart';
import 'committee_members_screen.dart';
import 'church_donations_screen.dart';
import 'payment_settings_screen.dart';

class ChurchInfoScreen extends StatefulWidget {
  final ChurchModel church;
  final bool isAdmin;

  const ChurchInfoScreen({
    super.key,
    required this.church,
    this.isAdmin = false,
  });

  @override
  State<ChurchInfoScreen> createState() => _ChurchInfoScreenState();
}

class _ChurchInfoScreenState extends State<ChurchInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openInMaps() async {
    if (widget.church.latitude == null || widget.church.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available for this church'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final lat = widget.church.latitude!;
    final lng = widget.church.longitude!;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.church.name.toUpperCase(),
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
        actions: [
          // Location button
          if (widget.church.latitude != null && widget.church.longitude != null)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: _openInMaps,
              tooltip: 'View on Maps',
            ),
          // Admin settings
          if (widget.isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'payment_settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSettingsScreen(
                        church: widget.church,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'payment_settings',
                  child: ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('Payment Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Members'),
            Tab(text: 'Sermons'),
            Tab(text: 'Worship'),
            Tab(text: 'Committee'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(church: widget.church),
          ChurchMembersScreen(
            churchId: widget.church.id,
            churchName: widget.church.name,
          ),
          SermonsListScreen(
            churchId: widget.church.id,
            churchName: widget.church.name,
          ),
          SongsListScreen(
            churchId: widget.church.id,
            churchName: widget.church.name,
          ),
          CommitteeMembersScreen(
            churchId: widget.church.id,
            churchName: widget.church.name,
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final ChurchModel church;

  const _OverviewTab({required this.church});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Church Logo and Name Header
          ChurchHeader(church: church, showLogo: true),

          const SizedBox(height: 24),

          // Church Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (church.description != null)
                    Text(
                      church.description!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    )
                  else
                    Text(
                      'No description available',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Contact Information
                  Text(
                    'Contact Information',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (church.pastorName != null)
                    _InfoRow(
                      icon: Icons.person,
                      label: 'Pastor',
                      value: church.pastorName!,
                    ),
                  if (church.phoneNumber != null)
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: church.phoneNumber!,
                    ),
                  if (church.email != null)
                    _InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: church.email!,
                    ),
                  if (church.city != null || church.area.isNotEmpty)
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: church.city != null
                          ? '${church.area}, ${church.city}'
                          : church.area,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _QuickActionCard(
                icon: Icons.music_note,
                title: 'Worship Songs',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongsListScreen(
                        churchId: church.id,
                        churchName: church.name,
                      ),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.mic,
                title: 'Sermons',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SermonsListScreen(
                        churchId: church.id,
                        churchName: church.name,
                      ),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.volunteer_activism,
                title: 'Donate',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChurchDonationsScreen(
                        church: church,
                      ),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.people,
                title: 'Members',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChurchMembersScreen(
                        churchId: church.id,
                        churchName: church.name,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
