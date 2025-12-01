import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/vaults_screen.dart';
import 'package:mobile/services/api.dart';
import 'package:mobile/services/auth_store.dart';

void main() {
  runApp(const MyApp());
}

const _defaultBase = 'http://10.0.2.2:8080';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Api _api = Api(baseUrl: _defaultBase);
  final AuthStore _store = AuthStore();

  Future<Widget> _decideHome() async {
    final token = await _store.loadToken();
    final userId = await _store.loadUserId();
    if (token != null && userId != null) {
      return VaultsScreen(token: token, userId: userId, api: _api);
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agam Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _decideHome(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return snapshot.data!;
        },
      ),
    );
  }
}
