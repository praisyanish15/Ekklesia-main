import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/church_service.dart';
import '../../models/church_model.dart';
import '../church/songs_list_screen.dart';

class WorshipTab extends StatefulWidget {
  const WorshipTab({super.key});

  @override
  State<WorshipTab> createState() => _WorshipTabState();
}

class _WorshipTabState extends State<WorshipTab> {
  final ChurchService _churchService = ChurchService();
  ChurchModel? _userChurch;
  bool _isLoading = false;
  String? _lastChurchId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserChurch();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when user data changes (e.g., after joining a church)
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // Reload if churchId changed (user joined a new church or left)
    if (user?.churchId != _lastChurchId && !_isLoading) {
      _lastChurchId = user?.churchId;
      _loadUserChurch();
    }
  }

  Future<void> _loadUserChurch() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user?.churchId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userChurch = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final church = await _churchService.getChurchById(user!.churchId!);
      if (mounted) {
        setState(() {
          _userChurch = church;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // If user hasn't joined a church
        if (user?.churchId == null || _userChurch == null) {
          return _NoChurchView();
        }

        // Show songs list for the user's church
        return SongsListScreen(
          churchId: _userChurch!.id,
          churchName: _userChurch!.name,
        );
      },
    );
  }
}

class _NoChurchView extends StatelessWidget {
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
              Icons.music_note,
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
              'Join a church to access worship songs and lyrics',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/join-church');
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/church-search');
              },
              icon: const Icon(Icons.search),
              label: const Text('Find Church'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
