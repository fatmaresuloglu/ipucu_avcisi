// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Firebase CLI ile oluşturulan yapılandırma dosyasını import ediyoruz
import 'firebase_options.dart';

// Yeni başlangıç ekranımızı import ediyoruz
import 'screens/category_selection_screen.dart';

// 💡 TOPLU VERİ YÜKLEME FONKSİYONUNU VE VERİSİNİ İMPORT EDİN
import 'data_loader.dart';

void main() async {
  // Firebase başlatma için gereklidir
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i platforma özel seçeneklerle başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Emulator için ayarlar (debug modunda)
  // if (kDebugMode) {
  //   // ⚠️ EĞER FIREBASE EMULATOR KULLANMIYORSANIZ BU SATIRI YORUMA ALIN!
  //   // Gerçek Cloud Firestore kullanıyorsanız bu ayar olmamalı.
  //   FirebaseFirestore.instance.settings = const Settings(
  //     host: 'localhost:8080',
  //     sslEnabled: false,
  //     persistenceEnabled: false,
  //   );
  // }

  // 💡 VERİ YÜKLEME ÇAĞRISI (Sadece bir kerelik çalıştırmak için!)
  // Veriyi Firebase'e yüklemek için BU SATIRI aktif bırakın:
  //await loadInitialDataToFirestore();

  // 🚨 DİKKAT: Veri yüklendikten sonra bu satırı yoruma alın veya silin:
  // await loadInitialDataToFirestore();

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
