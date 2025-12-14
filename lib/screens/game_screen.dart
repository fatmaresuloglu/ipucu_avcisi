// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import 'score_screen.dart';
import '../models/hint_item.dart';
import '../models/game_state.dart';

class GameScreen extends ConsumerWidget {
  final String category;

  const GameScreen({required this.category, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 gameNotifierProvider'ı izle (state değiştiğinde rebuild olur)
    final gameState = ref.watch(gameNotifierProvider(category));

    // Metotları çağırmak için controller'ı oku
    final gameController = ref.read(gameNotifierProvider(category).notifier);

    // 💡 currentItem'ı doğrudan izlenen state'ten al
    final currentItem = gameState.currentItem;

    // Oyun bitti mi kontrolü
    final isTimeUpOrFinished =
        gameState.timeRemaining <= 0 ||
        (currentItem == null && gameState.playedItemIds.isNotEmpty);

    // ******************************************************
    // TUR BİTİŞİ VE NAVİGASYON MANTIĞI
    // ******************************************************
    if (isTimeUpOrFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ScoreScreen(finalState: gameState),
            ),
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // ******************************************************

    // Eğer kelime yüklenmediyse
    if (currentItem == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Ekranda gösterilecek ana kartı belirle
    Widget currentCard = gameState.isAnswerRevealed
        ? _buildAnswerCard(context, currentItem, gameController)
        : _buildHintCard(context, currentItem, gameController);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Zamanlayıcı ve Skor Bilgisi
            _buildHeader(gameState.timeRemaining, gameState.score),

            // Kart Çevirme Alanı
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          final rotate = Tween(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(animation);
                          return AnimatedBuilder(
                            animation: rotate,
                            child: child,
                            builder: (BuildContext context, Widget? child) {
                              final double rotationAngle =
                                  rotate.value * 3.14159;
                              final bool isBack = rotationAngle > 3.14159 / 2;

                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(
                                  isBack
                                      ? rotationAngle - 3.14159
                                      : rotationAngle,
                                ),
                                child: child,
                              );
                            },
                          );
                        },
                    child: currentCard,
                  ),
                ),
              ),
            ),

            // Cevap ortaya çıkınca butonları göster
            if (gameState.isAnswerRevealed)
              _buildActionButtons(context, gameController, isTimeUpOrFinished),

            // Cevap gizliyken UI zıplamasını engellemek için boşluk
            if (!gameState.isAnswerRevealed) const SizedBox(height: 120 + 20),
          ],
        ),
      ),
    );
  }

  // --- İpucu Kartı (Ön Yüz) ---
  Widget _buildHintCard(
    BuildContext context,
    HintItem currentItem,
    GameNotifier controller,
  ) {
    return InkWell(
      key: ValueKey(currentItem.id),
      onTap: () {
        controller.revealAnswer();
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: double.infinity,
          height: 350,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.deepPurple.shade50,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '❓ Bu ne?',
                style: TextStyle(fontSize: 24, color: Colors.deepPurple),
              ),
              const SizedBox(height: 20),
              // İpuçlarını listele
              ...currentItem.hints.map((hint) => _buildHintText(hint)),
              const Spacer(),
              const Icon(Icons.touch_app, size: 40, color: Colors.deepPurple),
              const Text(
                'Cevabı görmek için dokun',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Cevap Kartı (Arka Yüz) ---
  Widget _buildAnswerCard(
    BuildContext context,
    HintItem currentItem,
    GameNotifier controller,
  ) {
    Widget answerContent;
    final String answerValue = currentItem.answer;
    final bool isImageUrl = answerValue.startsWith('http');

    if (currentItem.category == 'Şehir') {
      answerContent = Text(
        currentItem.title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    } else {
      answerContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. RESİM KISMI
          if (isImageUrl)
            Image.network(
              answerValue,
              height: 150,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.red,
                );
              },
            )
          else
            const Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.white70,
            ),

          const SizedBox(height: 20),

          // 2. YAZI KISMI (Kelimenin Adı)
          Text(
            currentItem.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return Card(
      key: ValueKey(currentItem.id),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        height: 350,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.deepPurple.shade700,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CEVAP',
              style: TextStyle(fontSize: 20, color: Colors.white70),
            ),
            Expanded(child: Center(child: answerContent)),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  // 💡 EKSİK YARDIMCI METOTLARIN TANIMLARI
  // -----------------------------------------------------------------

  Widget _buildHeader(int time, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildTimerWidget(time), _buildScoreWidget(score)],
      ),
    );
  }

  Widget _buildTimerWidget(int time) {
    final color = time <= 10 ? Colors.red.shade700 : Colors.deepPurple;

    return Column(
      children: [
        Icon(Icons.timer, size: 30, color: color),
        Text(
          '$time',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreWidget(int score) {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 30,
          color: Colors.green.shade600,
        ),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHintText(String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '• $hint',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // AKSİYON BUTONLARI: Doğru/Yanlış/Pas Geç
  Widget _buildActionButtons(
    BuildContext context,
    GameNotifier controller,
    bool isGameOver,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20.0,
        left: 10,
        right: 10,
        top: 20,
      ),
      child: Row(
        children: [
          // Pas Geç Butonu (Sol)
          Expanded(
            child: InkWell(
              onTap: isGameOver ? null : () => controller.markSkip(),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fast_forward, size: 30, color: Colors.white),
                    SizedBox(height: 5),
                    Text(
                      'PAS GEÇ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Yanlış Butonu
          Expanded(
            child: InkWell(
              onTap: isGameOver
                  ? null
                  : () => controller
                        .markSkip(), // Yanlış seçeneği de pas olarak işlenebilir
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, size: 30, color: Colors.white),
                    SizedBox(height: 5),
                    Text(
                      'YANLIŞ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Doğru Butonu (Sağ)
          Expanded(
            child: InkWell(
              onTap: isGameOver ? null : () => controller.markCorrect(),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 30, color: Colors.white),
                    SizedBox(height: 5),
                    Text(
                      'DOĞRU',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
