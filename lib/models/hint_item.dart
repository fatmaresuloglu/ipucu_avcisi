class HintItem {
  final String id;
  final String category; // Örn: 'Hayvan', 'Şehir', 'Eşya'
  final String name; // Tahmin edilecek kelime (Örn: "ZÜRAFA")
  final List<String> hints; // İpucu listesi (5 adet)
  final bool isPro; // Ücretli içeriğe ait olup olmadığı

  HintItem({
    required this.id,
    required this.category,
    required this.name,
    required this.hints,
    this.isPro = false,
  });

  // Firestore'dan gelen veriyi (Map) Dart objesine çeviren factory metot
  factory HintItem.fromFirestore(Map<String, dynamic> data, String id) {
    return HintItem(
      id: id,
      category: data['category'] ?? 'Genel',
      name: data['name'] ?? 'Bilinmiyor',
      // Firestore'dan List<dynamic> olarak gelebilir, List<String>'e çeviriyoruz
      hints: List<String>.from(data['hints'] ?? []),
      isPro: data['isPro'] ?? false,
    );
  }

  // Dart objesini Firestore'a göndermek için Map'e çeviren metot
  Map<String, dynamic> toFirestore() {
    return {'category': category, 'name': name, 'hints': hints, 'isPro': isPro};
  }
}
