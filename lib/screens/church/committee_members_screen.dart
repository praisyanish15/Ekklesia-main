import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/committee_member_model.dart';
import '../../services/committee_service.dart';

class CommitteeMembersScreen extends StatefulWidget {
  final String churchId;
  final String churchName;

  const CommitteeMembersScreen({
    super.key,
    required this.churchId,
    required this.churchName,
  });

  @override
  State<CommitteeMembersScreen> createState() => _CommitteeMembersScreenState();
}

class _CommitteeMembersScreenState extends State<CommitteeMembersScreen> {
  final CommitteeService _committeeService = CommitteeService();
  Map<String, List<CommitteeMember>> _committeeMembers = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCommitteeMembers();
  }

  Future<void> _loadCommitteeMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final members =
          await _committeeService.getCommitteeMembersByPosition(widget.churchId);

      setState(() {
        _committeeMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int get _totalMembers =>
      _committeeMembers.values.fold(0, (sum, list) => sum + list.length);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Committee Members',
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
                          'Error loading committee',
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
                          onPressed: _loadCommitteeMembers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _totalMembers == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No committee members yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Committee members will be appointed by church administrators',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCommitteeMembers,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // President
                          if (_committeeMembers['president']!.isNotEmpty) ...[
                            _PositionHeader(
                              icon: Icons.workspace_premium,
                              title: 'President',
                            ),
                            const SizedBox(height: 12),
                            ..._committeeMembers['president']!
                                .map((member) => _CommitteeMemberCard(
                                      member: member,
                                      showFullDetails: true,
                                    )),
                            const SizedBox(height: 24),
                          ],

                          // Secretary
                          if (_committeeMembers['secretary']!.isNotEmpty) ...[
                            _PositionHeader(
                              icon: Icons.edit_note,
                              title: 'Secretary',
                            ),
                            const SizedBox(height: 12),
                            ..._committeeMembers['secretary']!
                                .map((member) => _CommitteeMemberCard(
                                      member: member,
                                      showFullDetails: true,
                                    )),
                            const SizedBox(height: 24),
                          ],

                          // Treasurer
                          if (_committeeMembers['treasurer']!.isNotEmpty) ...[
                            _PositionHeader(
                              icon: Icons.account_balance_wallet,
                              title: 'Treasurer',
                            ),
                            const SizedBox(height: 12),
                            ..._committeeMembers['treasurer']!
                                .map((member) => _CommitteeMemberCard(
                                      member: member,
                                      showFullDetails: true,
                                    )),
                            const SizedBox(height: 24),
                          ],

                          // Committee Members
                          if (_committeeMembers['member']!.isNotEmpty) ...[
                            _PositionHeader(
                              icon: Icons.people,
                              title: 'Committee Members',
                            ),
                            const SizedBox(height: 12),
                            ..._committeeMembers['member']!
                                .map((member) => _CommitteeMemberCard(
                                      member: member,
                                      showFullDetails: true,
                                    )),
                          ],

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }
}

class _PositionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PositionHeader({
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

class _CommitteeMemberCard extends StatelessWidget {
  final CommitteeMember member;
  final bool showFullDetails;

  const _CommitteeMemberCard({
    required this.member,
    this.showFullDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Photo
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  backgroundImage: member.photoUrl != null
                      ? NetworkImage(member.photoUrl!)
                      : null,
                  child: member.photoUrl == null
                      ? Icon(
                          Icons.person,
                          size: 36,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.displayPosition,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (showFullDetails) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Email
              if (member.email != null)
                _ContactInfo(
                  icon: Icons.email_outlined,
                  label: member.email!,
                ),

              // Phone
              if (member.phoneNumber != null) ...[
                const SizedBox(height: 8),
                _ContactInfo(
                  icon: Icons.phone_outlined,
                  label: member.phoneNumber!,
                ),
              ],

              // Address
              if (member.address != null) ...[
                const SizedBox(height: 8),
                _ContactInfo(
                  icon: Icons.location_on_outlined,
                  label: member.address!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.textTheme.bodyMedium?.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
