// lib/models/hint_item.dart (Güncellenmiş Hali)

class HintItem {
  final String id;
  final String category;
  final List<String> hints;
  final String answer; // Resim URL'si
  final String title; // <-- YENİ ALAN: Kelimenin adı

  HintItem({
    required this.id,
    required this.category,
    required this.hints,
    required this.answer,
    required this.title, // <-- Constructor'a eklendi
  });

  // Factory metodu (Firestore'dan veri okumak için)
  factory HintItem.fromFirestore(Map<String, dynamic> data, String id) {
    return HintItem(
      id: id,
      category: data['category'] as String? ?? 'Bilinmiyor',
      hints:
          (data['hints'] as List?)?.map((item) => item.toString()).toList() ??
          [],
      answer: data['answer'] as String? ?? 'Cevap Bulunamadı',
      title:
          data['title'] as String? ??
          'Başlık Bulunamadı', // <-- Firestore'dan okunur
    );
  }
}
