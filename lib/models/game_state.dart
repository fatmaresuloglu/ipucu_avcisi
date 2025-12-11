// lib/models/game_state.dart

class GameState {
  final String category; // Oynanan kategori
  final int score; // Doğru tahmin sayısı
  final int skipCount; // Pas geçme sayısı
  final int timeRemaining; // Kalan saniye
  final List<String> playedItemIds; // Oynanmış kelimelerin ID'leri
  final bool isAnswerRevealed; // <-- YENİ ALAN: Cevabın görünüp görünmediği

  const GameState({
    required this.category,
    this.score = 0,
    this.skipCount = 0,
    this.timeRemaining = 60, // Başlangıç süresi 60 saniye
    this.playedItemIds = const [],
    this.isAnswerRevealed = false, // <-- Varsayılan olarak gizli
  });

  // Durumu güncellemek için kopyalama metodu (Riverpod için kritik)
  GameState copyWith({
    int? score,
    int? skipCount,
    int? timeRemaining,
    List<String>? playedItemIds,
    bool? isAnswerRevealed, // <-- YENİ ALAN
  }) {
    return GameState(
      category: category,
      score: score ?? this.score,
      skipCount: skipCount ?? this.skipCount,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      playedItemIds: playedItemIds ?? this.playedItemIds,
      isAnswerRevealed:
          isAnswerRevealed ?? this.isAnswerRevealed, // <-- YENİ KOPYALAMA
    );
  }
}
