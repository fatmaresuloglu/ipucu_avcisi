// lib/models/hint_item.dart

class HintItem {
  final String id;
  final String category;
  final List<String> hints;
  final String
  answer; // <-- YENİ ALAN: Doğru cevabın kendisi (Kelime veya Resim URL'si)

  HintItem({
    required this.id,
    required this.category,
    required this.hints,
    required this.answer, // <-- CONSTRUCTOR'a eklendi
  });

  // Factory metodu (Firebase Firestore'dan veri okumak için)
  factory HintItem.fromFirestore(Map<String, dynamic> data, String id) {
    return HintItem(
      id: id,
      category: data['category'] as String? ?? 'Bilinmiyor',
      hints:
          (data['hints'] as List?)?.map((item) => item.toString()).toList() ??
          [],
      answer:
          data['answer'] as String? ??
          'Cevap Bulunamadı', // <-- Firestore'dan okundu
    );
  }
}
