import 'package:documind/app.dart';
import 'package:documind/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:responsive_framework/responsive_framework.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyDyc3XU8wRxi879Fbb18GX1MkybkrLpU2k',
        appId: '1:465879871086:web:6d3032380a6a2c9ec5807f',
        messagingSenderId: '465879871086',
        projectId: 'documind-e0969',
        authDomain: 'documind-e0969.firebaseapp.com',
        storageBucket: 'documind-e0969.firebasestorage.app',
        measurementId: 'G-X0KEM36W45',
      ),
    );
  }
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
      home: App(),
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
