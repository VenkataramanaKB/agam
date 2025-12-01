import 'package:flutter/material.dart';
import 'package:mobile/services/api.dart';

class CreateVaultScreen extends StatefulWidget {
  final Api api;
  final String token;
  final int userId;
  const CreateVaultScreen({super.key, required this.api, required this.token, required this.userId});

  @override
  State<CreateVaultScreen> createState() => _CreateVaultScreenState();
}

class _CreateVaultScreenState extends State<CreateVaultScreen> {
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController(text: 'default');
  bool _loading = false;

  void _submit() async {
    setState(() => _loading = true);
    try {
      final v = await widget.api.createVault(widget.token, _nameCtrl.text.trim(), _typeCtrl.text.trim(), widget.userId);
      if (!mounted) return;
      Navigator.of(context).pop(v);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Vault')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: _typeCtrl, decoration: const InputDecoration(labelText: 'Type')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Create')),
        ]),
      ),
    );
  }
}
