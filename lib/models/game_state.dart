// lib/models/game_state.dart

import 'hint_item.dart';

class GameState {
  final String category;
  final int timeRemaining;
  final int score;
  final int skipCount;
  final List<String> playedItemIds;
  final bool isAnswerRevealed;

  // 💡 YENİ ALAN: Şu anki kelimeyi state içinde taşıyoruz
  final HintItem? currentItem;

  const GameState({
    required this.category,
    this.timeRemaining = 30, // Varsayılan başlangıç süresi
    this.score = 0,
    this.skipCount = 0,
    this.playedItemIds = const [],
    this.isAnswerRevealed = false,
    this.currentItem, // 💡 Constructor'a ekle
  });

  GameState copyWith({
    String? category,
    int? timeRemaining,
    int? score,
    int? skipCount,
    List<String>? playedItemIds,
    bool? isAnswerRevealed,
    HintItem? currentItem, // 💡 copyWith metoduna ekle
  }) {
    return GameState(
      category: category ?? this.category,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      score: score ?? this.score,
      skipCount: skipCount ?? this.skipCount,
      playedItemIds: playedItemIds ?? this.playedItemIds,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}
