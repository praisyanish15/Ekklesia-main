import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../church/church_search_screen.dart';
import '../bible/bible_screen.dart';
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
    const NotificationsScreen(),
    const DonationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekklesia'),
        actions: [
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              setState(() {
                _selectedIndex = 3;
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

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Welcome, ${user?.name ?? 'Guest'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'May God bless you today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
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
                    icon: Icons.add_business,
                    title: 'Create Church',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).pushNamed('/create-church');
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.group_add,
                    title: 'Join Church',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).pushNamed('/join-church');
                    },
                  ),
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
            ],
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
