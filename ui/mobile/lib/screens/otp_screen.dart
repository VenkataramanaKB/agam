import 'package:flutter/material.dart';
import 'package:mobile/services/api.dart';
import 'package:mobile/services/auth_store.dart';
import 'vaults_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final Api api;
  final int userId;
  const OtpScreen({super.key, required this.email, required this.api, required this.userId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  bool _loading = false;

  void _verify() async {
    setState(() => _loading = true);
    try {
      final resp = await widget.api.verifyOtp(widget.email, _otpCtrl.text.trim());
      final store = AuthStore();
      await store.saveToken(resp.token);
      await store.saveUserId(resp.userId);

      // Register device if not present
      final existingDevice = await store.loadDeviceId();
      if (existingDevice == null || existingDevice.isEmpty) {
        try {
          final deviceId = await widget.api.registerDevice(resp.token, 'mobile-device', resp.userId);
          if (deviceId.isNotEmpty) await store.saveDeviceId(deviceId);
        } catch (_) {
          // don't block login on device registration failure
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => VaultsScreen(token: resp.token, userId: resp.userId, api: widget.api)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Text('OTP sent to ${widget.email}'),
          TextField(controller: _otpCtrl, decoration: const InputDecoration(labelText: 'OTP')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _verify, child: _loading ? const CircularProgressIndicator() : const Text('Verify')),
        ]),
      ),
    );
  }
}
