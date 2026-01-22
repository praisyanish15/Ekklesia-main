import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/song_model.dart';

class SongDetailScreen extends StatelessWidget {
  final Song song;

  const SongDetailScreen({
    super.key,
    required this.song,
  });

  Future<void> _openInMaps(BuildContext context) async {
    if (song.latitude == null || song.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available for this song'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final lat = song.latitude!;
    final lng = song.longitude!;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openLink(BuildContext context) async {
    if (song.link == null) return;

    final url = Uri.parse(song.link!);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
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
          'SONG DETAILS',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        elevation: 0,
        actions: [
          // Copy lyrics button
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy lyrics',
            onPressed: () {
              Clipboard.setData(ClipboardData(
                text: '${song.title}\n${song.artist != null ? "by ${song.artist}\n" : ""}\n${song.lyrics}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lyrics copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          // Location button (if available)
          if (song.latitude != null && song.longitude != null)
            IconButton(
              icon: const Icon(Icons.directions),
              tooltip: 'Get Directions',
              onPressed: () => _openInMaps(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Song header
            Center(
              child: Column(
                children: [
                  // Music icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.music_note,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),

                  // Artist
                  if (song.artist != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          song.artist!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Category and Language badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (song.category != null)
                        Chip(
                          label: Text(song.category!),
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ),
                      Chip(
                        label: Text(song.language.toUpperCase()),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Musical Info Section
            if (song.key != null || song.chords != null) ...[
              _SectionHeader(
                icon: Icons.piano,
                title: 'Musical Information',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (song.key != null)
                        _InfoRow(
                          icon: Icons.music_note_outlined,
                          label: 'Key',
                          value: song.key!,
                        ),
                      if (song.key != null && song.chords != null)
                        const SizedBox(height: 12),
                      if (song.chords != null)
                        _InfoRow(
                          icon: Icons.piano,
                          label: 'Chords',
                          value: song.chords!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Location Section
            if (song.location != null ||
                (song.latitude != null && song.longitude != null)) ...[
              _SectionHeader(
                icon: Icons.location_on,
                title: 'Location',
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (song.location != null)
                        Text(
                          song.location!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (song.latitude != null && song.longitude != null) ...[
                        if (song.location != null) const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openInMaps(context),
                            icon: const Icon(Icons.directions),
                            label: const Text('Get Directions'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // External Link
            if (song.link != null) ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.link,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('Watch/Listen Online'),
                  subtitle: Text(
                    song.link!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openLink(context),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Lyrics Section
            _SectionHeader(
              icon: Icons.lyrics,
              title: 'Lyrics',
            ),
            const SizedBox(height: 16),

            // Lyrics content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: SelectableText(
                song.lyrics,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.8,
                  letterSpacing: 0.3,
                ),
              ),
            ),
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

    return Row(
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
    );
  }
}
