// card_grid.dart

import 'package:flutter/material.dart';
import '../screens/card_detail_page.dart';

class BuildCardGrid extends StatelessWidget {
  final List<dynamic> filteredCards;
  final List<dynamic> cards;
  final List<String> deckCards;
  final void Function(Map<String, dynamic>) onAddCard;
  final void Function(String imagePath) onRemoveCard;

  const BuildCardGrid({
    super.key,
    required this.filteredCards,
    required this.cards,
    required this.deckCards,
    required this.onAddCard,
    required this.onRemoveCard,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: filteredCards.isEmpty
          ? const Center(child: Text('No cards found.'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 0,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredCards.length,
              itemBuilder: (context, index) {
                final card = filteredCards[index];
                final id = card['id'];
                final imagePath = 'assets/images/$id.png';

                return GestureDetector(
                  onTap: () => onAddCard(card),
                  onLongPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardDetailPage(card: card),
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, color: Colors.white);
                          },
                        ),
                      ),
                      if (deckCards.contains(imagePath))
                        Positioned(
                          top: 4,
                          left: 4,
                          child: GestureDetector(
                            onTap: () => onRemoveCard(imagePath),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.remove, color: Colors.red, size: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
