import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/church_service.dart';

class ChurchMembersScreen extends StatefulWidget {
  final String churchId;
  final String churchName;
  final bool embedded; // True when used as a tab (no Scaffold)

  const ChurchMembersScreen({
    super.key,
    required this.churchId,
    required this.churchName,
    this.embedded = false,
  });

  @override
  State<ChurchMembersScreen> createState() => _ChurchMembersScreenState();
}

class _ChurchMembersScreenState extends State<ChurchMembersScreen> {
  final ChurchService _churchService = ChurchService();
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get all approved members (exclude pending)
      final members = await _churchService.getChurchMembers(widget.churchId);

      setState(() {
        _members = members
            .where((m) => m['role'] != 'pending')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      // Check if table doesn't exist yet
      if (errorStr.contains('pgrst205') ||
          errorStr.contains('could not find the') ||
          errorStr.contains('schema cache')) {
        // Table doesn't exist - show empty state
        setState(() {
          _members = [];
          _isLoading = false;
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
                        'Error loading members',
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
                        onPressed: _loadMembers,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : _members.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No members yet',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Members will appear here once they join ${widget.churchName}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadMembers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        return _MemberCard(member: member);
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
          'Members',
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

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;

  const _MemberCard({required this.member});

  String _getRoleBadgeText(String role) {
    switch (role) {
      case 'super_admin':
        return 'Church Leader';
      case 'admin':
        return 'Admin';
      case 'committee':
        return 'Committee';
      case 'member':
        return 'Member';
      default:
        return role;
    }
  }

  Color _getRoleBadgeColor(String role, ColorScheme colorScheme) {
    switch (role) {
      case 'super_admin':
        return const Color(0xFFD4A574); // Soft Gold
      case 'admin':
        return const Color(0xFFE8B88B); // Light Soft Gold
      case 'committee':
        return const Color(0xFFB8956A); // Darker Soft Gold
      default:
        return colorScheme.primary.withValues(alpha: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = member['name'] ?? 'Unknown';
    final address = member['address'] ?? '';
    final role = member['role'] ?? 'member';

    // Extract country/place from address (last part after comma)
    String location = 'Location not specified';
    if (address.isNotEmpty) {
      final parts = address.split(',');
      location = parts.isNotEmpty ? parts.last.trim() : address;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              backgroundImage: member['photo_url'] != null
                  ? NetworkImage(member['photo_url'])
                  : null,
              child: member['photo_url'] == null
                  ? Icon(
                      Icons.person,
                      size: 32,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Name and Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleBadgeColor(role, theme.colorScheme),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRoleBadgeText(role),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: role == 'super_admin' || role == 'admin' || role == 'committee'
                      ? const Color(0xFF0B1929)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
