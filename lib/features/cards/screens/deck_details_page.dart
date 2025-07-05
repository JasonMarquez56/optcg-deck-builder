import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/card_detail_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class DeckDetailsPage extends StatefulWidget {
  final String leaderPath;
  final String deckId;

  const DeckDetailsPage({
    required this.leaderPath,
    required this.deckId,
    super.key,
  });

  @override
  State<DeckDetailsPage> createState() => _DeckDetailsPageState();
}

class _DeckDetailsPageState extends State<DeckDetailsPage> {
  Map<String, int> uniqueCardCounts = {};
  bool loading = true;
  List<Map<String, dynamic>> allCards = []; // You need to provide this list

  @override
  void initState() {
    super.initState();
    // Load your full cards list here or pass it in some other way before this page uses it
    // For example, you might want to pass it via constructor or fetch it from a provider
    loadAllCards();
    loadDeckFromFirestore();
  }

  Future<void> loadAllCards() async {
    final jsonString = await rootBundle.loadString('assets/cards.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      allCards = jsonList.cast<Map<String, dynamic>>();
    });
  }

  Future<void> loadDeckFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => loading = false);
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('decks')
        .doc(widget.deckId)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('cards')) {
        final List<dynamic> rawCards = data['cards'];
        final Map<String, int> counts = {};
        for (final path in rawCards) {
          counts[path] = (counts[path] ?? 0) + 1;
        }

        setState(() {
          uniqueCardCounts = counts;
          loading = false;
        });
        return;
      }
    }

    setState(() {
      uniqueCardCounts = {};
      loading = false;
    });
  }

  Map<String, dynamic>? getCardByPath(String path) {
    try {
      return allCards.firstWhere((c) => 'assets/images/${c['id']}.png' == path);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniquePaths = uniqueCardCounts.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(
                      children: [
                        Container(
                          width: 150,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Image.asset(
                            widget.leaderPath,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Leader',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: uniquePaths.isEmpty
                        ? const Center(
                            child: Text(
                              'No cards found in this deck.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.60,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: uniquePaths.length,
                            itemBuilder: (context, index) {
                              final path = uniquePaths[index];
                              final count = uniqueCardCounts[path]!;
                              final card = getCardByPath(path);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (card != null) {
                                        print('Navigating to card: ${card['name']}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CardDetailPage(card: card),
                                          ),
                                        );
                                      } else {
                                        print('Card data not found for path: $path');
                                      }
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: Colors.grey[900],
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        path,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'x$count',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
