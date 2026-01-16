import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/sermon_model.dart';

class SermonDetailScreen extends StatelessWidget {
  final Sermon sermon;

  const SermonDetailScreen({
    super.key,
    required this.sermon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sermon Details',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(sermon.date),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              sermon.title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Pastor
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 20,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pastor ${sermon.pastorName}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),

            // Description
            if (sermon.description != null && sermon.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                sermon.description!,
                style: theme.textTheme.bodyLarge,
              ),
            ],

            // Key Points Section
            if (sermon.keyPoints.isNotEmpty) ...[
              const SizedBox(height: 32),
              _SectionHeader(
                icon: Icons.lightbulb_outline,
                title: 'Key Points',
              ),
              const SizedBox(height: 16),
              ...sermon.keyPoints.asMap().entries.map((entry) {
                return _KeyPointCard(
                  number: entry.key + 1,
                  point: entry.value,
                );
              }),
            ],

            // Bible Verses Section
            if (sermon.verses.isNotEmpty) ...[
              const SizedBox(height: 32),
              _SectionHeader(
                icon: Icons.menu_book,
                title: 'Scripture References',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sermon.verses.map((verse) {
                  return _VerseChip(verse: verse);
                }).toList(),
              ),
            ],

            // Media Section
            if (sermon.audioUrl != null || sermon.videoUrl != null) ...[
              const SizedBox(height: 32),
              _SectionHeader(
                icon: Icons.play_circle_outline,
                title: 'Media',
              ),
              const SizedBox(height: 16),
              if (sermon.videoUrl != null)
                _MediaButton(
                  icon: Icons.video_library,
                  label: 'Watch Video',
                  url: sermon.videoUrl!,
                ),
              if (sermon.audioUrl != null) ...[
                if (sermon.videoUrl != null) const SizedBox(height: 12),
                _MediaButton(
                  icon: Icons.audiotrack,
                  label: 'Listen to Audio',
                  url: sermon.audioUrl!,
                ),
              ],
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _KeyPointCard extends StatelessWidget {
  final int number;
  final String point;

  const _KeyPointCard({
    required this.number,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFF0B1929)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Point text
            Expanded(
              child: Text(
                point,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseChip extends StatelessWidget {
  final String verse;

  const _VerseChip({required this.verse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_stories,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            verse,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement media playback or URL launcher
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening: $url')),
        );
      },
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
}
