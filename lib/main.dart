import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Import Landing Page
import 'package:optcg_deck_builder/features/cards/screens/landing_page.dart';

// Your app's home page
import 'package:optcg_deck_builder/features/cards/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Works on all platforms
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Piece TCG Deck Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
