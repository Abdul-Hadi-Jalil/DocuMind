import 'package:documind/features/auth/screens/auth_screen.dart';
import 'package:documind/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DashboardScreen();
          } else {
            return AuthScreen();
          }
        },
      ),
    );
  }
}
