import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/sermon_model.dart';
import '../../services/sermon_service.dart';
import 'sermon_detail_screen.dart';

class SermonsListScreen extends StatefulWidget {
  final String churchId;
  final String churchName;

  const SermonsListScreen({
    super.key,
    required this.churchId,
    required this.churchName,
  });

  @override
  State<SermonsListScreen> createState() => _SermonsListScreenState();
}

class _SermonsListScreenState extends State<SermonsListScreen> {
  final SermonService _sermonService = SermonService();
  List<Sermon> _sermons = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSermons();
  }

  Future<void> _loadSermons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sermons = await _sermonService.getChurchSermons(widget.churchId);

      setState(() {
        _sermons = sermons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sermons',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading sermons',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadSermons,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _sermons.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sermons yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sermons will appear here once they are added by church administrators',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSermons,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sermons.length,
                        itemBuilder: (context, index) {
                          final sermon = _sermons[index];
                          return _SermonCard(
                            sermon: sermon,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SermonDetailScreen(
                                    sermon: sermon,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _SermonCard extends StatelessWidget {
  final Sermon sermon;
  final VoidCallback onTap;

  const _SermonCard({
    required this.sermon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dateFormat.format(sermon.date),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                sermon.title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Pastor name
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pastor ${sermon.pastorName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),

              // Description preview if available
              if (sermon.description != null && sermon.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  sermon.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],

              const SizedBox(height: 12),

              // Key points count and verses count
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.format_list_bulleted,
                    label: '${sermon.keyPoints.length} Points',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.menu_book,
                    label: '${sermon.verses.length} Verses',
                  ),
                  if (sermon.audioUrl != null || sermon.videoUrl != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      sermon.videoUrl != null
                          ? Icons.video_library
                          : Icons.audiotrack,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
