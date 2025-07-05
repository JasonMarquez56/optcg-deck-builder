import 'package:flutter/material.dart';

class CardDetailPage extends StatelessWidget {
  final Map<String, dynamic> card;

  // Height of the expanded image area
  final double imageHeight;

  const CardDetailPage({
    super.key,
    required this.card,
    this.imageHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    final id = card['id'];
    final name = card['name'];
    //final color = card['color'];
    //final cardClass = card['card_class'];
    final rarity = card['rarity'];
    final imagePath = 'assets/images/$id.png';

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            // SliverAppBar with collapsing image and back button
            SliverAppBar(
              pinned: true,
              expandedHeight: 50,
              backgroundColor: Colors.black54,
              leading: Padding(
                //padding: const EdgeInsets.only(left: 8, top: 8),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Material(
                    color: Color.fromARGB(255, 26, 26, 26),
                    child: InkWell(
                      splashColor: Colors.white24,
                      onTap: () => Navigator.of(context).pop(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      
            // Sliver for the info container with rounded corners
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 10, 10, 10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 1, color: Color.fromARGB(255, 26, 26, 26)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePath,
                          scale: 2,                    
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, color: Colors.white);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('$name',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('$rarity ● $id', style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
