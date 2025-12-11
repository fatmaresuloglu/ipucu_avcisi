// lib/screens/score_screen.dart

import 'package:flutter/material.dart';
import '../models/game_state.dart';

class ScoreScreen extends StatelessWidget {
  final GameState finalState;

  const ScoreScreen({required this.finalState, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oyun Bitti!'),
        automaticallyImplyLeading: false, // Geri butonunu kaldırıyoruz
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎉 Tur Sonuçları 🎉',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 40),

              // Skor Kutusu
              _buildScoreBox('Doğru Tahmin', finalState.score, Colors.green),
              const SizedBox(height: 20),

              // Pas Sayısı Kutusu
              _buildScoreBox('Pas Sayısı', finalState.skipCount, Colors.amber),
              const SizedBox(height: 40),

              // Yeni Oyun Butonu
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Yeni Oyun Başlat',
                  style: TextStyle(fontSize: 20),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Tüm ekranları kapatıp kategori seçimine geri dön
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // lib/screens/score_screen.dart içinde, _buildScoreBox metodu

  // ... (diğer kodlar)

  Widget _buildScoreBox(String title, int value, Color color) {
    return Card(
      // ... (diğer widget'lar)
      child: Container(
        // ... (diğer dekorasyonlar)
        child: Column(
          children: [
            // ... (Title)
            const SizedBox(height: 10),
            Text(
              '$value',
              // Düzeltme: color.shade800 yerine color'ın kendisini kullanıyoruz
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
