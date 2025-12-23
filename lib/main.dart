import 'package:documind/features/auth/screens/landing_screen.dart';
import 'package:documind/features/auth/screens/login_screen.dart';
import 'package:documind/features/auth/screens/signup_screen.dart';
import 'package:documind/features/pdf_chat/pdf_chat_screen.dart';
import 'package:documind/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:responsive_framework/responsive_framework.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Documind());
}

class Documind extends StatelessWidget {
  const Documind({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocuMind AI',
      theme: ThemeData.dark(),
      home: PDFChatScreen(),
      debugShowCheckedModeBanner: false,
      /*
      // CORRECT responsive framework implementation
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
*/
    );
  }
}
