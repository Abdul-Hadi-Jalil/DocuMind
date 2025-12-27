import 'package:documind/features/auth/screens/landing_screen.dart';
import 'package:documind/features/auth/screens/login_screen.dart';
import 'package:documind/features/auth/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLoginScreen = false;
  bool showLandingScreen = true;

  void toggleScreen() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  void loginScreen() {
    setState(() {
      showLoginScreen = true;
      showLandingScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLandingScreen) {
      return LandingScreen(showLoginScreen: loginScreen);
    } else {
      if (showLoginScreen) {
        return LoginPage(showRegisterScreen: toggleScreen);
      } else {
        return SignUpPage(showLoginScreen: toggleScreen);
      }
    }
  }
}
