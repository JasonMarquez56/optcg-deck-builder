import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/deck_area.dart';
import '../widgets/card_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardGridPage extends StatefulWidget {
  const CardGridPage({super.key});

  @override
  State<CardGridPage> createState() => _CardGridPageState();
}

class _CardGridPageState extends State<CardGridPage> {
  List<dynamic> cards = [];
  List<dynamic> filteredCards = [];
  List<String> deckCards = [];

  final TextEditingController searchController = TextEditingController();
  Set<String> selectedColors = {};
  Set<String> selectedClasses = {};

  final List<String> availableColors = [
    'Red', 'Blue', 'Green', 'Purple', 'Black', 'Yellow'
  ];
  final List<String> availableClasses = [
    'LEADER', 'CHARACTER', 'EVENT', 'STAGE'
  ];

  @override
  void initState() {
    super.initState();
    loadCards();
    searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadCards() async {
    final String jsonString = await rootBundle.loadString('assets/cards.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    final filtered = jsonData.where((card) {
    final id = card['id'] ?? '';
    // Exclude cards that contain _p or _r before the file extension
    return !RegExp(r'_[pr]\d*$').hasMatch(id);
  }).toList();
    setState(() {
      cards = filtered;
      filteredCards = filtered;
    });
  }

  void _onAddCard(Map<String, dynamic> card) {
    final id = card['id'];
    final imagePath = 'assets/images/$id.png';
    final cardClass = card['card_class'] ?? '';
    final rawColor = card['color'] ?? '';
    final cardColors = rawColor.split('/').map((c) => c.trim()).toSet();

    final currentCount = deckCards.where((path) => path == imagePath).length;
    final isLeader = cardClass == 'LEADER';

    final hasLeader = deckCards.any((path) {
      final matchingCard = cards.firstWhere(
        (c) => 'assets/images/${c['id']}.png' == path,
        orElse: () => null,
      );
      return matchingCard != null && matchingCard['card_class'] == 'LEADER';
    });

    if (currentCount >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add up to 4 copies of a card.')),
      );
      return;
    }

    if (isLeader && hasLeader) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only one Leader card can be added.')),
      );
      return;
    }

    setState(() {
      if (isLeader) {
        // Remove any existing Leader
        deckCards.removeWhere((path) {
          final matchingCard = cards.firstWhere(
            (c) => 'assets/images/${c['id']}.png' == path,
            orElse: () => null,
          );
          return matchingCard != null && matchingCard['card_class'] == 'LEADER';
        });

        // Insert new Leader at position 0
        deckCards.insert(0, imagePath);

        // Update filters based on Leader color
        selectedClasses = {'CHARACTER', 'EVENT', 'STAGE'};
        selectedColors = cardColors.cast<String>();
        _applyFilters();
      } else if (deckCards.length < 51) {
        deckCards.add(imagePath);
      }
    });
  }


  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredCards = cards.where((card) {
        final name = card['name']?.toLowerCase() ?? '';
        final cardClass = card['card_class'] ?? '';
        final rawColor = card['color'] ?? '';
        final cardColors = rawColor.split('/').map((c) => c.trim()).toSet();
        final matchesSearch = name.contains(query);
        final colorMatch = selectedColors.isEmpty ||
            cardColors.any((color) => selectedColors.contains(color));
        final classMatch = selectedClasses.isEmpty || selectedClasses.contains(cardClass);
        return matchesSearch && colorMatch && classMatch;
      }).toList();
    });
  }

  dynamic getCardById(String id) {
    return cards.firstWhere((card) => card['id'] == id, orElse: () => null);
  }

  Future<void> _saveDeck() async {
    final user = FirebaseAuth.instance.currentUser;
    final hasLeader = deckCards.any((path) {
      final matchingCard = cards.firstWhere(
        (c) => 'assets/images/${c['id']}.png' == path,
        orElse: () => null,
      );
      return matchingCard != null && matchingCard['card_class'] == 'LEADER';
    });

    if (deckCards.length < 51) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A deck must have 51 cards.')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save a deck.')),
      );
      return;
    }

    if (!hasLeader) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must have 1 Leader card.')),
      );
      return;
    }

    final deckName = await _promptForDeckName();
    if (deckName == null || deckName.trim().isEmpty) return; 

    final decksRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('decks');

    await decksRef.add({
      'name': deckName.trim(),
      'cards': deckCards,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deck Saved!'))
      );
    }
  }

  Future<String?> _promptForDeckName() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Deck Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Deck name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget buildImageCard(String imagePath) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: 100,
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, color: Colors.white);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: Column(
              children: [
                SearchFilterBar(
                  context: context,
                  searchController: searchController,
                  selectedColors: selectedColors,
                  selectedClasses: selectedClasses,
                  availableColors: availableColors,
                  availableClasses: availableClasses,
                  onApply: (newColors, newClasses) {
                    setState(() {
                      selectedColors = newColors;
                      selectedClasses = newClasses;
                      _applyFilters();
                    });
                  },
                ),
                BuildDeckArea(
                  deckCards: deckCards,
                  cards: cards,
                  onRemoveCard: (path) {
                    setState(() {
                      deckCards.remove(path);
                    });
                  },
                ),
                BuildCardGrid(
                  filteredCards: filteredCards,
                  cards: cards,
                  deckCards: deckCards,
                  onAddCard: _onAddCard,
                  onRemoveCard: (path) {
                    setState(() {
                      deckCards.remove(path);
                    });
                  }
                )
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _saveDeck,
              icon: const Icon(Icons.save),
              label: const Text('Save Deck'),
              backgroundColor: Colors.white,
            ),
          ),
        ]
      ),
    );
  }
}