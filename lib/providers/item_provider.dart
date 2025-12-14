import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // debugPrint için
import '../models/hint_item.dart';

// ====================================================
// 1. YARDIMCI FONKSİYON: Kategoriye göre koleksiyon adını eşleştirme
// ====================================================

// Kategori adını (Örn: 'Hayvan') Firebase'deki koleksiyon adıyla (Örn: 'hayvanlar') eşleştirir.
String _getCollectionName(String category) {
  switch (category) {
    case 'Hayvan':
      return 'hayvanlar';
    case 'Şehir':
      return 'sehirler';
    case 'Eşya':
      return 'esyalar';
    default:
      // Varsayılan koleksiyon (eski yapıyla uyumluluk veya hata durumları için)
      return 'items';
  }
}

// ====================================================
// 2. ITEM REPOSITORY (Veritabanı İşlemleri)
// ====================================================

class ItemRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Belirli bir koleksiyondaki HintItem'ları Stream olarak döndürür (Gerçek zamanlı güncelleme)
  Stream<List<HintItem>> fetchItemsStreamByCategory(String category) {
    final collectionName = _getCollectionName(category);

    // Hata durumunda koleksiyon adı kontrolü
    if (collectionName == 'items') {
      debugPrint(
        'UYARI: Bilinmeyen kategori ($category). Varsayılan "items" koleksiyonu kullanılıyor.',
      );
    }

    // 1. Belirlenen koleksiyona referans
    final collectionRef = _db.collection(collectionName);

    // 2. Anlık veri akışını (snapshot) dinleme ve HintItem listesine dönüştürme
    return collectionRef
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return HintItem.fromFirestore(doc.data(), doc.id);
          }).toList();
        })
        .handleError((e) {
          // Stream üzerinde hata yönetimi
          debugPrint('Koleksiyondan veri çekme hatası ($collectionName): $e');
          return <HintItem>[]; // Hata durumunda boş bir liste akışı
        });
  }
}

// ====================================================
// 3. RIVERPOD PROVIDERS (Durum Yönetimi)
// ====================================================

// a) ItemRepository sınıfını sağlayan Provider (Değişmedi)
final itemRepositoryProvider = Provider((ref) => ItemRepository());

// b) Kategoriye göre filtrelenmiş veriyi TAAHMİN EDİLEN koleksiyondan çeken Family Stream Provider.
// Bu, seçilen kategoriye göre doğru koleksiyondan gerçek zamanlı veri çeker.
final itemsByCategoryProvider = StreamProvider.family<List<HintItem>, String>((
  ref,
  category,
) {
  // Repository örneğini alıyoruz
  final repository = ref.watch(itemRepositoryProvider);

  // Repository'deki Stream metodunu çağırarak gerçek zamanlı veri akışını döndürüyoruz.
  return repository.fetchItemsStreamByCategory(category);
});

// c) Tüm benzersiz kategori isimlerini bulan Provider (Eski hali)
// NOT: Çoklu koleksiyon yapısında, kategorileri çekmek için
// *TÜM* koleksiyonları taramanız gerekebilir.
// Ancak pratik bir çözüm olarak, kategorileri sabit bir listede tutmak daha yaygındır.
final allCategoriesProvider = Provider<List<String>>((ref) {
  // Oyununuzdaki sabit kategori listesini döndürün.
  // Bu, Firebase'i gereksiz yere sorgulamaktan kaçınır.
  return const ['Hayvan', 'Şehir', 'Eşya'];
});

// Artık önceki kodunuzdaki 'allItemsProvider' ve onun Future mantığına ihtiyacımız yok, 
// çünkü 'itemsByCategoryProvider' direkt olarak doğru koleksiyondan Stream olarak veri çekiyor.