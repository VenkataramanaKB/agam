import 'package:flutter/material.dart';
import 'package:mobile/services/api.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final api = Api(baseUrl: 'http://10.0.2.2:8080'); // adjust for your backend
    try {
      final resp = await api.login(_emailCtrl.text.trim(), _passCtrl.text);
      // Navigate to OTP screen
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OtpScreen(email: _emailCtrl.text.trim(), api: api, userId: resp.userId)));
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 8),
          TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
        ]),
      ),
    );
  }
}
