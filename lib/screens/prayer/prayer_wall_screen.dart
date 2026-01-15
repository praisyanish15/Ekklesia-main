import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/prayer_request_model.dart';
import '../../services/prayer_service.dart';
import 'submit_prayer_screen.dart';
import 'prayer_detail_screen.dart';

class PrayerWallScreen extends StatefulWidget {
  const PrayerWallScreen({super.key});

  @override
  State<PrayerWallScreen> createState() => _PrayerWallScreenState();
}

class _PrayerWallScreenState extends State<PrayerWallScreen>
    with SingleTickerProviderStateMixin {
  final _prayerService = PrayerService();
  late TabController _tabController;

  List<PrayerRequestModel> _publicPrayers = [];
  List<PrayerRequestModel> _privatePrayers = [];
  List<PrayerRequestModel> _leadershipPrayers = [];
  List<PrayerRequestModel> _answeredPrayers = [];
  PrayerCategory? _selectedCategory;
  bool _isLoading = true;
  bool _isLeadership = false;
  String? _churchId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPrayers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser?.currentChurchId == null) {
        throw Exception('Please join a church first');
      }

      _churchId = authProvider.currentUser!.currentChurchId;
      _isLeadership = authProvider.currentUser!.isLeadershipRole;

      final publicPrayers = await _prayerService.getPublicPrayers(
        churchId: _churchId!,
        category: _selectedCategory,
      );

      final privatePrayers = await _prayerService.getPrivatePrayers(
        churchId: _churchId!,
        userId: authProvider.currentUser!.id,
        isLeadership: _isLeadership,
      );

      List<PrayerRequestModel> leadershipPrayers = [];
      if (_isLeadership) {
        leadershipPrayers = await _prayerService.getLeadershipPrayers(
          churchId: _churchId!,
        );
      }

      final answeredPrayers = await _prayerService.getAnsweredPrayers(
        churchId: _churchId!,
      );

      setState(() {
        _publicPrayers = publicPrayers;
        _privatePrayers = privatePrayers;
        _leadershipPrayers = leadershipPrayers;
        _answeredPrayers = answeredPrayers;
      });
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Filter by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: _selectedCategory == null
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            title: const Text('All Categories'),
            onTap: () {
              setState(() {
                _selectedCategory = null;
              });
              Navigator.pop(context);
              _loadPrayers();
            },
          ),
          ...PrayerCategory.values.map((category) {
            final prayer = PrayerRequestModel(
              id: '',
              userId: '',
              userName: '',
              churchId: '',
              title: '',
              description: '',
              category: category,
              createdAt: DateTime.now(),
            );
            return ListTile(
              leading: _selectedCategory == category
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              title: Text(prayer.categoryDisplay),
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context);
                _loadPrayers();
              },
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prayer Wall'),
            Text(
              'ShepherdCare',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCategoryFilter,
            tooltip: 'Filter',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'Public', icon: Icon(Icons.public)),
            const Tab(text: 'Private', icon: Icon(Icons.lock)),
            if (_isLeadership)
              const Tab(text: 'Leadership', icon: Icon(Icons.admin_panel_settings)),
            const Tab(text: 'Answered', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrayerList(_publicPrayers, 'public'),
          _buildPrayerList(_privatePrayers, 'private'),
          if (_isLeadership)
            _buildPrayerList(_leadershipPrayers, 'leadership'),
          _buildPrayerList(_answeredPrayers, 'answered'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubmitPrayerScreen(),
            ),
          ).then((_) => _loadPrayers());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Prayer'),
      ),
    );
  }

  Widget _buildPrayerList(List<PrayerRequestModel> prayers, String type) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.church, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              type == 'answered'
                  ? 'No answered prayers yet'
                  : 'No prayer requests yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (type != 'answered')
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubmitPrayerScreen(),
                    ),
                  ).then((_) => _loadPrayers());
                },
                icon: const Icon(Icons.add),
                label: const Text('Share a prayer request'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrayers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prayers.length,
        itemBuilder: (context, index) {
          return _PrayerCard(
            prayer: prayers[index],
            isAnswered: type == 'answered',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PrayerDetailScreen(prayer: prayers[index]),
                ),
              ).then((_) => _loadPrayers());
            },
          );
        },
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerRequestModel prayer;
  final bool isAnswered;
  final VoidCallback onTap;

  const _PrayerCard({
    required this.prayer,
    this.isAnswered = false,
    required this.onTap,
  });

  IconData _getCategoryIcon() {
    switch (prayer.category) {
      case PrayerCategory.general:
        return Icons.chat_bubble_outline;
      case PrayerCategory.health:
        return Icons.healing;
      case PrayerCategory.family:
        return Icons.family_restroom;
      case PrayerCategory.financial:
        return Icons.attach_money;
      case PrayerCategory.spiritual:
        return Icons.auto_awesome;
      case PrayerCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(prayer.createdAt),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high, size: 14, color: Colors.red[800]),
                          const SizedBox(width: 4),
                          Text(
                            'Urgent',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isAnswered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green[800]),
                          const SizedBox(width: 4),
                          Text(
                            'Answered',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Category & Privacy
              Row(
                children: [
                  Icon(_getCategoryIcon(), size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    prayer.categoryDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    prayer.privacy == PrayerPrivacy.public
                        ? Icons.public
                        : prayer.privacy == PrayerPrivacy.private
                            ? Icons.lock
                            : Icons.admin_panel_settings,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    prayer.privacyDisplay,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                prayer.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description Preview
              Text(
                prayer.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${prayer.prayerCount} ${prayer.prayerCount == 1 ? 'person' : 'people'} prayed',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'Tap to pray',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 12, color: Colors.blue[700]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
