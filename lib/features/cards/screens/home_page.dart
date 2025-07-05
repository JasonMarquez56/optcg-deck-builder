import 'package:flutter/material.dart';
import 'package:optcg_deck_builder/features/cards/screens/card_grid_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:optcg_deck_builder/features/cards/screens/deck_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> decks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDecks();
  }

  Future<void> loadDecks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        decks = [];
        loading = false;
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('decks')
        .get();

    final loadedDecks = snapshot.docs.map((doc) {
      final cardsListDynamic = doc['cards'] ?? [];
      // Ensure cardsList is a List<String>
      final cardsList = List<String>.from(cardsListDynamic);

      // Get leaderPath from first card id or fallback image
      final leaderPath = cardsList.isNotEmpty
          ? cardsList[0]
          : 'assets/images/default.png';

      print('leader path: $leaderPath');

      return {
        'id': doc.id,
        'name': doc['name'] ?? 'Unnamed Deck',
        'cards': cardsList,
        'leaderPath': leaderPath,
        'cardCount': cardsList.length,
      };
    }).toList();

    setState(() {
      decks = loadedDecks;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : decks.isEmpty
                    ? const Center(child: Text('No decks found.', style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: decks.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final deck = decks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DeckDetailsPage(leaderPath: deck['leaderPath'], deckId: deck['id']))
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 24, 24, 24),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color.fromARGB(255, 26, 26, 26), width: 2),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      deck['leaderPath'],
                                      width: 100,
                                      height: 130,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          deck['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${deck['cardCount']} cards',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Create Deck"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CardGridPage()),
                ).then((_) => loadDecks()); // reload decks after returning
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 26, 26, 26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
