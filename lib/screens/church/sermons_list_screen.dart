import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/sermon_model.dart';
import '../../services/sermon_service.dart';
import 'sermon_detail_screen.dart';

class SermonsListScreen extends StatefulWidget {
  final String churchId;
  final String churchName;
  final bool embedded; // True when used as a tab (no Scaffold)

  const SermonsListScreen({
    super.key,
    required this.churchId,
    required this.churchName,
    this.embedded = false,
  });

  @override
  State<SermonsListScreen> createState() => _SermonsListScreenState();
}

class _SermonsListScreenState extends State<SermonsListScreen> {
  final SermonService _sermonService = SermonService();
  List<Sermon> _sermons = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _featureComingSoon = false;

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
      // Check if error is due to missing table (feature not yet available)
      final errorStr = e.toString().toLowerCase();
      // Check for various error patterns that indicate table doesn't exist
      // PGRST205 = relation not found in PostgREST
      final isMissingTable = errorStr.contains('pgrst205') ||
          errorStr.contains('could not find the') ||
          errorStr.contains('schema cache') ||
          (errorStr.contains('relation') && errorStr.contains('does not exist'));

      if (isMissingTable) {
        // Table doesn't exist yet - show as coming soon
        setState(() {
          _sermons = [];
          _isLoading = false;
          _featureComingSoon = true;
        });
      } else {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _featureComingSoon
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mic,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sermons Coming Soon!',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We\'re working on bringing you sermon recordings and notes. Stay tuned!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Icon(
                        Icons.construction,
                        size: 32,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              )
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
                                color: theme.colorScheme.primary.withValues(alpha: 0.5),
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
                      );

    // When embedded in a tab, don't wrap in Scaffold
    if (widget.embedded) {
      return content;
    }

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
      body: content,
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
