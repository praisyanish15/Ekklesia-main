import 'package:flutter/material.dart';
import '../../models/church_model.dart';
import '../../services/church_service.dart';

class ChurchSearchScreen extends StatefulWidget {
  const ChurchSearchScreen({super.key});

  @override
  State<ChurchSearchScreen> createState() => _ChurchSearchScreenState();
}

class _ChurchSearchScreenState extends State<ChurchSearchScreen> {
  final ChurchService _churchService = ChurchService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  List<ChurchModel> _churches = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllChurches();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _loadAllChurches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final churches = await _churchService.getAllChurches();
      setState(() {
        _churches = churches;
        _hasSearched = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading churches: ${e.toString()}'),
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

  Future<void> _searchChurches() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final churches = await _churchService.searchChurches(
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        area: _areaController.text.trim().isNotEmpty
            ? _areaController.text.trim()
            : null,
      );
      setState(() {
        _churches = churches;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Fields
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Church Name',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.church),
              suffixIcon: _nameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _nameController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _areaController,
            decoration: InputDecoration(
              labelText: 'Area',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.location_on),
              suffixIcon: _areaController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _areaController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _searchChurches,
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasSearched
                    ? _churches.isEmpty
                        ? const Center(
                            child: Text(
                              'No churches found',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _churches.length,
                            itemBuilder: (context, index) {
                              final church = _churches[index];
                              return _ChurchCard(church: church);
                            },
                          )
                    : const Center(
                        child: Text(
                          'Search for a church by name or area',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ChurchCard extends StatelessWidget {
  final ChurchModel church;

  const _ChurchCard({required this.church});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              church.photoUrl != null ? NetworkImage(church.photoUrl!) : null,
          child: church.photoUrl == null
              ? const Icon(Icons.church)
              : null,
        ),
        title: Text(
          church.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (church.area.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14),
                  const SizedBox(width: 4),
                  Expanded(child: Text(church.area)),
                ],
              ),
            if (church.address != null)
              Text(
                church.address!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to church details
          showDialog(
            context: context,
            builder: (context) => _ChurchDetailsDialog(church: church),
          );
        },
      ),
    );
  }
}

class _ChurchDetailsDialog extends StatelessWidget {
  final ChurchModel church;

  const _ChurchDetailsDialog({required this.church});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(church.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (church.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  church.photoUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            _DetailRow(icon: Icons.location_on, text: church.area),
            if (church.address != null)
              _DetailRow(icon: Icons.home, text: church.address!),
            if (church.city != null)
              _DetailRow(icon: Icons.location_city, text: church.city!),
            if (church.phoneNumber != null)
              _DetailRow(icon: Icons.phone, text: church.phoneNumber!),
            if (church.email != null)
              _DetailRow(icon: Icons.email, text: church.email!),
            if (church.description != null) ...[
              const SizedBox(height: 12),
              const Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(church.description!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            // Join church functionality
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Joined ${church.name}'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Join Church'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
