import 'package:documind/features/image_generation/image_generation_screen.dart';
import 'package:documind/features/ocr/ocr_screen.dart';
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
      home: OcrScreen(),
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
