import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/church_service.dart';
import '../../models/church_model.dart';
import '../../models/user_model.dart';
import '../../widgets/banner_ad_widget.dart';
import '../church/church_search_screen.dart';
import '../church/church_info_screen.dart';
import '../bible/bible_screen.dart';
import '../worship/worship_tab.dart';
import '../notifications/notifications_screen.dart';
import '../donations/donations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ChurchSearchScreen(),
    const BibleScreen(),
    const WorshipTab(),
    const NotificationsScreen(),
    const DonationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EKKLESIA',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              setState(() {
                _selectedIndex = 4;
              });
            },
          ),

          // Profile Photo in AppBar
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PopupMenuButton(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Profile'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context).pushNamed('/profile');
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.group_add),
                        title: Text('Join Church'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context).pushNamed('/join-church');
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.add_business),
                        title: Text('Create Church'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context).pushNamed('/create-church');
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        Future.delayed(Duration.zero, () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.church),
            label: 'Churches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bible',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Worship',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donations',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ChurchService _churchService = ChurchService();
  ChurchModel? _userChurch;
  bool _isLoadingChurch = false;

  @override
  void initState() {
    super.initState();
    _loadUserChurch();
  }

  Future<void> _loadUserChurch() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user?.churchId == null) return;

    setState(() => _isLoadingChurch = true);

    try {
      final church = await _churchService.getChurchById(user!.churchId!);
      setState(() => _userChurch = church);
    } catch (e) {
      // Silently fail - user might not have church or church was deleted
    } finally {
      setState(() => _isLoadingChurch = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return RefreshIndicator(
          onRefresh: _loadUserChurch,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                Text(
                  'Welcome, ${user?.name ?? 'Guest'}!',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'May God bless you today',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // My Church Section
                if (user?.churchId != null) ...[
                  Text(
                    'My Church',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingChurch)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (_userChurch != null)
                    _MyChurchCard(
                      church: _userChurch!,
                      isAdmin: user?.role == UserRole.admin,
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Unable to load church information',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _QuickActionCard(
                      icon: Icons.church,
                      title: 'Find Church',
                      onTap: () {
                        Navigator.of(context).pushNamed('/church-search');
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.book,
                      title: 'Read Bible',
                      onTap: () {
                        Navigator.of(context).pushNamed('/bible');
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.music_note,
                      title: 'Worship',
                      color: Colors.deepPurple,
                      onTap: () {
                        // Switch to Worship tab
                        final homeScreen = context.findAncestorStateOfType<_HomeScreenState>();
                        homeScreen?.setState(() {
                          homeScreen._selectedIndex = 3;
                        });
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.volunteer_activism,
                      title: 'Donate',
                      onTap: () {
                        Navigator.of(context).pushNamed('/donations');
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.auto_awesome,
                      title: 'Testimony Vault',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(context).pushNamed('/testimony-vault');
                      },
                    ),
                    _QuickActionCard(
                      icon: Icons.event,
                      title: 'Events',
                      onTap: () {
                        // Navigate to events
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Banner Ad
                const BannerAdWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 48, color: color ?? Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
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

class _MyChurchCard extends StatelessWidget {
  final ChurchModel church;
  final bool isAdmin;

  const _MyChurchCard({
    required this.church,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChurchInfoScreen(
                church: church,
                isAdmin: isAdmin,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Church Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                      image: church.photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(church.photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: church.photoUrl == null
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : null,
                    ),
                    child: church.photoUrl == null
                        ? Icon(
                            Icons.church,
                            color: theme.colorScheme.primary,
                            size: 30,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Church Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          church.name.toUpperCase(),
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (church.area.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  church.area,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
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

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Quick links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ChurchQuickLink(
                    icon: Icons.people,
                    label: 'Members',
                  ),
                  _ChurchQuickLink(
                    icon: Icons.mic,
                    label: 'Sermons',
                  ),
                  _ChurchQuickLink(
                    icon: Icons.music_note,
                    label: 'Worship',
                  ),
                  _ChurchQuickLink(
                    icon: Icons.volunteer_activism,
                    label: 'Donate',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChurchQuickLink extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChurchQuickLink({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
