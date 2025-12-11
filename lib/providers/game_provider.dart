// lib/providers/game_provider.dart

// ignore_for_file: avoid_print

import 'dart:async';
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
  HintItem? currentItem; // Şu anki oynanan kelime

  // Constructor
  GameNotifier(this.ref, String category)
    : super(GameState(category: category)) {
    _initializeGame(category);
  }

  // Kategorinin tüm kelimelerini yükle ve oyunu başlat
  void _initializeGame(String category) async {
    final items = ref.read(itemsByCategoryProvider(category));

    _allItems = items;

    // Eğer veri yüklendiyse ve liste boş değilse
    if (_allItems.isNotEmpty) {
      _selectNextItem();
      _startTimer();
    } else {
      print(
        'Hata: Seçilen kategoriye (${category}) ait veri yüklenemedi veya bulunamadı.',
      );
    }
  }

  // YENİ METOT: Cevabı ortaya çıkarır (Kartı çevirme anı)
  void revealAnswer() {
    // Cevap zaten görünürse tekrar çağırma
    if (state.isAnswerRevealed) return;

    state = state.copyWith(isAnswerRevealed: true);
    // Kart çevrildiğinde zamanlayıcıyı durdur, oyuncuya karar verme süresi ver
    _timer?.cancel();
  }

  void _startTimer() {
    _timer?.cancel(); // Mevcut zamanlayıcı varsa iptal et
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _timer?.cancel();
        print('Oyun bitti! Skor: ${state.score}');
      }
    });
  }

  // Kelime seçimini ve kart sıfırlama/ilerletme mantığını birleştirir
  void _selectNextItem() {
    // Önceki öğe ID'sini oynanmış listesine ekle
    if (currentItem != null) {
      state = state.copyWith(
        playedItemIds: [...state.playedItemIds, currentItem!.id],
        isAnswerRevealed: false, // <-- KART DURUMUNU SIFIRLA
      );
    }

    // Oynanmamış kelimeleri filtrele
    final availableItems = _allItems
        .where((item) => !state.playedItemIds.contains(item.id))
        .toList();

    if (availableItems.isEmpty) {
      currentItem = null;
      _timer?.cancel();
      print('Tüm kelimeler oynandı! Skor: ${state.score}');
      return;
    }

    // Rastgele bir kelime seç
    final random = Random();
    currentItem = availableItems[random.nextInt(availableItems.length)];

    // Yeni kelime seçildiyse ve süre bitmediyse zamanlayıcıyı başlat
    if (currentItem != null &&
        state.timeRemaining > 0 &&
        state.isAnswerRevealed == false) {
      _startTimer();
    }
  }

  void markCorrect() {
    // YENİ KONTROL: Sadece cevap göründüyse (kart çevrildiyse) skorlama yap
    if (currentItem == null || !state.isAnswerRevealed) return;

    // Skoru artır
    state = state.copyWith(score: state.score + 1);

    // Yeni kelimeyi seç ve kartı sıfırla (bu işlem _selectNextItem içinde yapılıyor)
    _selectNextItem();
  }

  void markSkip() {
    // YENİ KONTROL: Sadece cevap göründüyse (kart çevrildiyse) pas geç
    if (currentItem == null || !state.isAnswerRevealed) return;

    // Pas sayısını artır
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
