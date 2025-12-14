import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/item_provider.dart'; // allCategoriesProvider burada tanımlı
import 'game_screen.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // allCategoriesProvider'ı dinliyoruz.
    // Bu provider artık item_provider.dart içinde sabit listeyi döndürüyor.
    final categories = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İpucu Avcısı: Kategori Seç'),
        backgroundColor: Colors.deepPurple,
      ),
      body: categories.isEmpty
          ? const Center(
              // Sabit listeyi kullandığımız için burası sadece liste boşsa görünür.
              child: Text(
                'Kategori verisi bulunmuyor. Lütfen item_provider dosyasını kontrol edin.',
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Yan yana 2 kart
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.2, // Kart oranını ayarla
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(category: category);
              },
            ),
    );
  }
}

// Kategori Seçim Kartı Bileşeni (Değişmedi)
class CategoryCard extends StatelessWidget {
  final String category;

  const CategoryCard({required this.category, super.key});

  // Basit bir kategori ikonunu isme göre belirleyelim
  IconData _getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hayvan':
        return Icons.pets;
      case 'şehir':
        return Icons.location_city;
      case 'eşya':
        return Icons.lightbulb_outline;
      default:
        return Icons.casino; // Diğerleri için varsayılan
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Oyun ekranına category'yi göndererek geçiş yapılacak
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameScreen(category: category),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(category),
              size: 50,
              color: Colors.deepPurple.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
