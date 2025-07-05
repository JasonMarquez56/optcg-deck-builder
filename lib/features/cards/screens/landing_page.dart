import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// The app's home page
import 'package:optcg_deck_builder/features/cards/screens/home_page.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();

  Future<void> registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final userName = _userNameController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'userName': userName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registered and stored user data!")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage())
        );
      }

    } catch (e) {
      print('Register error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      // Create user doc if it doesn't exist
      if (!userDoc.exists) {
        await userDocRef.set({
          'email': email,
          'userName': _userNameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final data = (await userDocRef.get()).data()!;
      final userName = data['userName'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logged in as $userName")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage())
        );
      }
      
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Color.fromARGB(255, 0, 0, 0),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white)
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Color.fromARGB(255, 0, 0, 0),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white)
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Color.fromARGB(255, 0, 0, 0),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white)
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                  onPressed: registerUser,
                  child: Text('Register'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: loginUser,
                  child: Text('Login'),
                ),
                ]
              ),
            ]
          ),
        ),
      ),
    );
  }

}