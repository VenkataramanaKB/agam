import 'package:flutter/material.dart';
import 'package:mobile/services/api.dart';
import 'package:mobile/models.dart';
import 'create_vault_screen.dart';
import 'vault_detail_screen.dart';

class VaultsScreen extends StatefulWidget {
  final String token;
  final int userId;
  final Api api;
  const VaultsScreen({super.key, required this.token, required this.userId, required this.api});

  @override
  State<VaultsScreen> createState() => _VaultsScreenState();
}

class _VaultsScreenState extends State<VaultsScreen> {
  late Future<List<Vault>> _vaultsFuture;

  @override
  void initState() {
    super.initState();
    _vaultsFuture = widget.api.listVaults(widget.token, widget.userId);
  }

  void _refresh() {
    setState(() {
      _vaultsFuture = widget.api.listVaults(widget.token, widget.userId);
    });
  }

  void _createDemo() async {
    try {
      final v = await widget.api.createVault(widget.token, 'New Vault', 'default', widget.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created vault ${v.name}')));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Vaults'), actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))]),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        // open create form
        final created = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateVaultScreen(api: widget.api, token: widget.token, userId: widget.userId)));
        if (created != null) _refresh();
      }, child: const Icon(Icons.add)),
      body: FutureBuilder<List<Vault>>(
        future: _vaultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final vaults = snapshot.data ?? [];
          if (vaults.isEmpty) return const Center(child: Text('No vaults'));
          return ListView.builder(
            itemCount: vaults.length,
            itemBuilder: (context, i) {
              final v = vaults[i];
              return ListTile(
                title: Text(v.name),
                subtitle: Text(v.type),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => VaultDetailScreen(api: widget.api, token: widget.token, userId: widget.userId, vault: v)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
