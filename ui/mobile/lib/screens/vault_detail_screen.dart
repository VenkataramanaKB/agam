import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/services/api.dart';
import 'package:mobile/services/auth_store.dart';
import 'package:mobile/models.dart';

class VaultDetailScreen extends StatefulWidget {
  final Api api;
  final String token;
  final int userId;
  final Vault vault;
  const VaultDetailScreen({super.key, required this.api, required this.token, required this.userId, required this.vault});

  @override
  State<VaultDetailScreen> createState() => _VaultDetailScreenState();
}

class _VaultDetailScreenState extends State<VaultDetailScreen> {
  List<ThumbnailItem> thumbnails = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnails();
  }

  Future<void> _loadThumbnails() async {
    setState(() => loading = true);
    try {
      final t = await widget.api.getThumbnails(widget.token, widget.userId, widget.vault.id);
      if (!mounted) return;
      setState(() => thumbnails = t);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load thumbnails: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);
    if (file == null) return;
    setState(() => loading = true);
    try {
      // load stored device id; if missing, try registering this device
      final store = AuthStore();
      var deviceId = await store.loadDeviceId();
      if (deviceId == null || deviceId.isEmpty) {
        // attempt to register device with backend
        try {
          final newId = await widget.api.registerDevice(widget.token, 'mobile-device', widget.userId);
          if (newId.isNotEmpty) {
            await store.saveDeviceId(newId);
            deviceId = newId;
          }
        } catch (e) {
          // registration failed; surface meaningful error to user
          throw Exception('device registration failed: $e');
        }
      }
      if (deviceId == null || deviceId.isEmpty) {
        throw Exception('invalid device_id');
      }
      await widget.api.uploadFile(widget.token, deviceId, widget.vault.id, File(file.path));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded')));
      _loadThumbnails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vault.name), actions: [IconButton(onPressed: _loadThumbnails, icon: const Icon(Icons.refresh))]),
      floatingActionButton: FloatingActionButton(onPressed: _pickAndUpload, child: const Icon(Icons.upload_file)),
      body: loading ? const Center(child: CircularProgressIndicator()) : thumbnails.isEmpty ? const Center(child: Text('No files')) : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: thumbnails.length,
        itemBuilder: (context, i) => GestureDetector(
              onTap: () async {
                final item = thumbnails[i];
                try {
                  // Fetch bytes through server streaming endpoint (authenticated)
                  final bytes = await widget.api.fetchFileBytes(widget.token, widget.userId, item.fileId, thumbnail: false);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      insetPadding: const EdgeInsets.all(8),
                      child: InteractiveViewer(
                        child: Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch file: $e')));
                }
              },
              child: FutureBuilder<List<int>>(
                future: widget.api.fetchFileBytes(widget.token, widget.userId, thumbnails[i].fileId, thumbnail: true),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return Container(color: Colors.grey.shade100);
                  }
                  if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image, size: 36, color: Colors.grey)),
                    );
                  }
                  final bytes = snap.data!;
                  return Image.memory(Uint8List.fromList(bytes), fit: BoxFit.cover);
                },
              ),
            ),
      ),
    );
  }
}
