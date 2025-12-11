import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/hint_item.dart'; // HintItem modelinizi doğru yoluyla import edin

// ====================================================
// 1. ITEMS REPOSITORY (Veritabanı İşlemleri)
// ====================================================

class ItemRepository {
  // Firebase Firestore'un bir örneğini alıyoruz.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Tüm HintItem'ları (tahmin edilecek kelimeleri) Firestore'dan çeker
  Future<List<HintItem>> fetchAllItems() async {
    try {
      // 'items' koleksiyonundan tüm belgeleri çekiyoruz.
      final snapshot = await _db.collection('items').get();

      // Çekilen her bir belgeyi HintItem modeline dönüştürüyoruz.
      return snapshot.docs.map((doc) {
        return HintItem.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      // Hata yönetimi (Gerçek uygulamada loglama yapılmalıdır)
      debugPrint('Veri çekme hatası: $e');
      return []; // Hata durumunda boş bir liste döndür
    }
  }
}

// ====================================================
// 2. RIVERPOD PROVIDERS (Durum Yönetimi)
// ====================================================

// a) ItemRepository sınıfını sağlayan Provider.
// Bu, diğer sağlayıcıların veritabanı mantığına erişmesini sağlar.
final itemRepositoryProvider = Provider((ref) => ItemRepository());

// b) Tüm veriyi asenkron çeken FutureProvider.
// UI'da (CategorySelectionScreen) yükleniyor, hata ve data durumlarını yönetmek için kullanılır.
final allItemsProvider = FutureProvider<List<HintItem>>((ref) async {
  // Repository örneğini alıyoruz
  final repository = ref.watch(itemRepositoryProvider);

  // Veritabanından tüm veriyi çekiyoruz
  return repository.fetchAllItems();
});

// c) Kategoriye göre filtrelenmiş veriyi tutan Family Provider.
// Bu sağlayıcı, bir kategori adı (String) alarak ilgili kelimeleri döndürür.
final itemsByCategoryProvider = Provider.family<List<HintItem>, String>((
  ref,
  category,
) {
  // allItemsProvider'dan gelen verinin yüklenmesini bekler.
  final allItemsAsync = ref.watch(allItemsProvider);

  return allItemsAsync.when(
    data: (items) {
      // Sadece istenen kategoriye ait öğeleri filtreler ve döndürür.
      return items.where((item) => item.category == category).toList();
    },
    // Veri yüklenirken veya hata oluşursa boş liste döndürülür.
    loading: () => [],
    error: (err, stack) => [],
  );
});

// d) Tüm benzersiz kategori isimlerini bulan Provider
final allCategoriesProvider = Provider<List<String>>((ref) {
  final allItemsAsync = ref.watch(allItemsProvider);

  return allItemsAsync.when(
    data: (items) {
      // Tüm öğelerden sadece kategori isimlerini alır ve Set ile benzersizleştirir.
      return items.map((e) => e.category).toSet().toList();
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});
