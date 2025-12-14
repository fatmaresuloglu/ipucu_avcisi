// lib/providers/game_provider.dart

// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/hint_item.dart';
import 'item_provider.dart';
import 'dart:math';

// ----------------------------------------------------
// 1. GAME STATE NOTIFIER (Oyun Mantığı Kontrolcüsü)
// ----------------------------------------------------

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;
  Timer? _timer;
  List<HintItem> _allItems = []; // Kategorinin tüm kelimeleri
  // HintItem? currentItem; // 🛑 BU SATIR SİLİNDİ, artık state içinde.

  // Constructor
  GameNotifier(this.ref, String category)
    : super(GameState(category: category)) {
    _initializeGame(category);
  }

  // Kategorinin tüm kelimelerini yükle ve oyunu başlat
  void _initializeGame(String category) {
    // StreamProvider'dan gelen veriyi AsyncValue olarak okuyoruz
    final itemsAsync = ref.read(itemsByCategoryProvider(category));

    // Verinin yüklenip yüklenmediğini kontrol edip liste tipine dönüştürüyoruz.
    final List<HintItem> items = itemsAsync.value ?? [];

    _allItems = items;

    debugPrint(
      'Firebase\'den gelen kelime sayısı ($category): ${_allItems.length}',
    );

    // Eğer veri yüklendiyse ve liste boş değilse
    if (_allItems.isNotEmpty) {
      _selectNextItem(isInitial: true); // İlk başlatma için true gönder
      _startTimer(); // Zamanlayıcıyı başlat
    } else {
      debugPrint(
        'Hata: Seçilen kategoriye ($category) ait veri yüklenemedi veya bulunamadı.',
      );
    }
  }

  void revealAnswer() {
    // Cevap zaten görünürse tekrar çağırma
    if (state.isAnswerRevealed) return;

    state = state.copyWith(isAnswerRevealed: true);
    // Kart çevrildiğinde zamanlayıcıyı durdur, oyuncuya karar verme süresi ver
    _timer?.cancel();
  }

  void _startTimer() {
    // Eğer süre zaten 0 ise veya oyun bitmişse başlatma
    if (state.timeRemaining <= 0) return;

    _timer?.cancel(); // Mevcut zamanlayıcı varsa iptal et
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _timer?.cancel();
        debugPrint('Zaman bitti! Skor: ${state.score}');
        // Oyun bitti, burada ek bir bitiş state'ine geçilebilir.
      }
    });
  }

  // Kelime seçimini ve kart sıfırlama/ilerletme mantığını birleştirir
  void _selectNextItem({bool isInitial = false}) {
    // 1. Önceki öğe ID'sini oynanmış listesine ekle (İlk başlatma değilse)
    if (!isInitial && state.currentItem != null) {
      state = state.copyWith(
        playedItemIds: [...state.playedItemIds, state.currentItem!.id],
        isAnswerRevealed: false, // KART DURUMUNU SIFIRLA
      );
    }

    // 2. Oynanmamış kelimeleri filtrele
    final availableItems = _allItems
        .where((item) => !state.playedItemIds.contains(item.id))
        .toList();

    if (availableItems.isEmpty) {
      // 💡 state.currentItem'ı null yap
      state = state.copyWith(currentItem: null);
      _timer?.cancel();
      debugPrint('Tüm kelimeler oynandı! Skor: ${state.score}');
      return;
    }

    // 3. Rastgele bir kelime seç
    final random = Random();
    final nextItem = availableItems[random.nextInt(availableItems.length)];

    // 💡 currentItem değişkeni yerine state'i güncelleyin
    state = state.copyWith(currentItem: nextItem);

    // Yeni kelime seçildi ve oyun hala oynanıyorsa zamanlayıcıyı başlat
    if (!isInitial && state.timeRemaining > 0) {
      _startTimer();
    }
  }

  void markCorrect() {
    // Kontrol: Sadece cevap göründüyse skorlama yap
    if (state.currentItem == null || !state.isAnswerRevealed) return;

    // Skoru artır
    state = state.copyWith(score: state.score + 1);

    // Yeni kelimeyi seç ve kartı sıfırla
    _selectNextItem();
  }

  void markSkip() {
    // Kontrol: Sadece cevap göründüyse pas geç
    if (state.currentItem == null || !state.isAnswerRevealed) return;

    // Pas sayısını artır (isteğe bağlı)
    state = state.copyWith(skipCount: state.skipCount + 1);

    // Yeni kelimeyi seç ve kartı sıfırla
    _selectNextItem();
  }

  // Widget dispose edildiğinde zamanlayıcıyı temizle
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ----------------------------------------------------
// 2. GAME PROVIDER (Oyun Turu Başlatıcı)
// ----------------------------------------------------

// Family Notifier Provider: Bir kategori adı alarak yeni bir oyun başlatır
final gameNotifierProvider =
    StateNotifierProvider.family<GameNotifier, GameState, String>(
      (ref, category) => GameNotifier(ref, category),
    );
