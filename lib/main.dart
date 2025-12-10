// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'firebase_options.dart'; // Bu dosya Firebase CLI ile oluşur

void main() async {
  // Firebase ve diğer native kodların çalışması için gerekli
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Eğer Firebase CLI ile yapılandırma yaptıysanız bu kodu kullanın.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Basit kurulum için:
  await Firebase.initializeApp(); // Firebase'i başlatıyoruz

  // Riverpod için uygulamayı ProviderScope ile sarmalıyoruz
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İpucu Avcısı',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito', // Örnek çocuk dostu font
      ),
      home: const PlaceholderScreen(), // İlk ekranımızı buraya koyacağız
    );
  }
}

// Şimdilik boş bir yer tutucu ekran
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('İpucu Avcısı Başlıyor!')));
  }
}
