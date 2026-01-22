import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/testimony_model.dart';
import '../../services/testimony_service.dart';
import 'submit_testimony_screen.dart';
import 'testimony_detail_screen.dart';

class TestimonyVaultScreen extends StatefulWidget {
  const TestimonyVaultScreen({super.key});

  @override
  State<TestimonyVaultScreen> createState() => _TestimonyVaultScreenState();
}

class _TestimonyVaultScreenState extends State<TestimonyVaultScreen>
    with SingleTickerProviderStateMixin {
  final _testimonyService = TestimonyService();
  late TabController _tabController;

  List<TestimonyModel> _featuredTestimonies = [];
  List<TestimonyModel> _allTestimonies = [];
  TestimonyCategory? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTestimonies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTestimonies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final featured = await _testimonyService.getFeaturedTestimonies();
      final all = await _testimonyService.getApprovedTestimonies(
        category: _selectedCategory,
      );

      setState(() {
        _featuredTestimonies = featured;
        _allTestimonies = all;
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
              _loadTestimonies();
            },
          ),
          ...TestimonyCategory.values.map((category) {
            final testimony = TestimonyModel(
              id: '',
              userId: '',
              userName: '',
              title: '',
              content: '',
              category: category,
              type: TestimonyType.text,
              status: TestimonyStatus.approved,
              createdAt: DateTime.now(),
            );
            return ListTile(
              leading: _selectedCategory == category
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              title: Text(testimony.categoryDisplay),
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context);
                _loadTestimonies();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Testimony Vault'),
            Text(
              'Revelation 12:11',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
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
          tabs: const [
            Tab(text: 'Featured', icon: Icon(Icons.star)),
            Tab(text: 'All Stories', icon: Icon(Icons.library_books)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeaturedTab(),
          _buildAllTestimoniesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubmitTestimonyScreen(),
            ),
          ).then((_) => _loadTestimonies());
        },
        icon: const Icon(Icons.add),
        label: const Text('Share Testimony'),
      ),
    );
  }

  Widget _buildFeaturedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_featuredTestimonies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No featured testimonies yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTestimonies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _featuredTestimonies.length,
        itemBuilder: (context, index) {
          return _TestimonyCard(
            testimony: _featuredTestimonies[index],
            isFeatured: true,
          );
        },
      ),
    );
  }

  Widget _buildAllTestimoniesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allTestimonies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedCategory != null
                  ? 'No testimonies in this category'
                  : 'No testimonies yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitTestimonyScreen(),
                  ),
                ).then((_) => _loadTestimonies());
              },
              icon: const Icon(Icons.add),
              label: const Text('Be the first to share!'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTestimonies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allTestimonies.length,
        itemBuilder: (context, index) {
          return _TestimonyCard(testimony: _allTestimonies[index]);
        },
      ),
    );
  }
}

class _TestimonyCard extends StatelessWidget {
  final TestimonyModel testimony;
  final bool isFeatured;

  const _TestimonyCard({
    required this.testimony,
    this.isFeatured = false,
  });

  IconData _getCategoryIcon() {
    switch (testimony.category) {
      case TestimonyCategory.healing:
        return Icons.healing;
      case TestimonyCategory.financialBreakthrough:
        return Icons.attach_money;
      case TestimonyCategory.salvation:
        return Icons.favorite;
      case TestimonyCategory.deliverance:
        return Icons.check_circle;
      case TestimonyCategory.provision:
        return Icons.card_giftcard;
      case TestimonyCategory.protection:
        return Icons.shield;
      case TestimonyCategory.answeredPrayer:
        return Icons.check_circle_outline;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestimonyDetailScreen(testimony: testimony),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: testimony.userPhotoUrl != null
                        ? NetworkImage(testimony.userPhotoUrl!)
                        : null,
                    child: testimony.userPhotoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          testimony.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM d, yyyy').format(testimony.createdAt),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[800]),
                          const SizedBox(width: 4),
                          Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Category
              Row(
                children: [
                  Icon(_getCategoryIcon(), size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    testimony.categoryDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                testimony.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Content Preview
              Text(
                testimony.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${testimony.likeCount}',
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 16),
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${testimony.viewCount}',
                      style: TextStyle(color: Colors.grey[600])),
                  const Spacer(),
                  if (testimony.type == TestimonyType.audio)
                    Icon(Icons.audiotrack, size: 20, color: Colors.grey[600]),
                  if (testimony.type == TestimonyType.video)
                    Icon(Icons.videocam, size: 20, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
