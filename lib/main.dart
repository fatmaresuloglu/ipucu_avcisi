// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase CLI ile oluşturulan yapılandırma dosyasını import ediyoruz
import 'firebase_options.dart';

// Yeni başlangıç ekranımızı import ediyoruz
import 'screens/category_selection_screen.dart';

void main() async {
  // Firebase başlatma için gereklidir
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i platforma özel seçeneklerle başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Bu, web/android/vb. için ayarları kullanır
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İpucu Avcısı',
      theme: ThemeData(
        // Tema ayarlarınız
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ), // Tema rengi
        fontFamily: 'Nunito',
        useMaterial3: true,
      ),
      // Uygulamanın başlangıç ekranı (CategorySelectionScreen)
      home: const CategorySelectionScreen(),
    );
  }
}
