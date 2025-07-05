import 'package:flutter/material.dart';
import '../screens/card_detail_page.dart';

class BuildDeckArea extends StatefulWidget {
  final List<String> deckCards;
  final List<dynamic> cards;
  final void Function(String) onRemoveCard;

  const BuildDeckArea({
    super.key,
    required this.deckCards,
    required this.cards,
    required this.onRemoveCard,
  });

  @override
  State<BuildDeckArea> createState() => _BuildDeckAreaState();
}

class _BuildDeckAreaState extends State<BuildDeckArea> {
  final ScrollController _scrollController = ScrollController();

  dynamic getCardById(String id) {
    return widget.cards.firstWhere((card) => card['id'] == id, orElse: () => null);
  }

  @override
  void didUpdateWidget(covariant BuildDeckArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Scroll only if a new card is added
    if (widget.deckCards.length > oldWidget.deckCards.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> imageCount = {};
    for (var path in widget.deckCards) {
      imageCount[path] = (imageCount[path] ?? 0) + 1;
    }

    // Sort so Leader cards come first
    final sortedEntries = imageCount.entries.toList()
      ..sort((a, b) {
        String getClass (String path) {
          final id = path.split('/').last.replaceAll('.png', '');
          final card = getCardById(id);
          return card?['card_class'] ?? '';
        }

        final aClass = getClass(a.key);
        final bClass = getClass(b.key);
        if (aClass == 'LEADER') return -1;
        if (bClass == 'LEADER') return 1;
        return 0;
      });

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 2, color: const Color.fromARGB(255, 26, 26, 26)),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: sortedEntries.map((entry) {
                  final path = entry.key;
                  final count = entry.value;
                  final id = path.split('/').last.replaceAll('.png', '');
                  final card = getCardById(id);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => widget.onRemoveCard(path),
                      onLongPress: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardDetailPage(card: card),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.asset(
                              path,
                              width: 90,
                              height: 135,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'x$count',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 12,
              child: Text(
                'Deck: ${widget.deckCards.length}/51',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
