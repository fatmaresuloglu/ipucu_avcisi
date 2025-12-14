// lib/data_loader.dart (Yeni Dosya Oluşturun)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // debugPrint için

// JSON'daki koleksiyon yapısını temsil eden bir harita
const Map<String, Map<String, dynamic>> initialData = {
  "hayvanlar": {
    "kedi1": {
      "category": "Hayvan",
      "title": "Kedi",
      "answer": "https://ornek.com/kedi.jpg",
      "hints": ["Miyavlar", "4 ayaklı", "Evcil"],
    },
    "kopek1": {
      "category": "Hayvan",
      "title": "Köpek",
      "answer": "https://ornek.com/kopek.jpg",
      "hints": ["Havlar", "Sadık", "Bekçi"],
    },
    // ... JSON dosyanızdaki tüm HAYVANLAR verisini buraya ekleyin
  },
  "sehirler": {
    "ankara1": {
      "category": "Şehir",
      "title": "Ankara",
      "answer": "Ankara",
      "hints": ["Başkent", "Anıtkabir", "Soğuk"],
    },
    // ... JSON dosyanızdaki tüm ŞEHİRLER verisini buraya ekleyin
  },
  "esyalar": {
    "masa1": {
      "category": "Eşya",
      "title": "Masa",
      "answer": "https://ornek.com/masa.jpg",
      "hints": ["Üzerine eşya konur", "4 ayağı var", "Ahşap olabilir"],
    },
    // ... JSON dosyanızdaki tüm EŞYALAR verisini buraya ekleyin
  },
};

// lib/data_loader.dart (Devamı)

Future<void> loadInitialDataToFirestore() async {
  final firestore = FirebaseFirestore.instance;

  debugPrint('--- Toplu Veri Yükleme Başladı ---');

  for (final collectionEntry in initialData.entries) {
    final collectionName = collectionEntry.key; // Örn: "hayvanlar"
    final documents = collectionEntry.value; // O koleksiyondaki dokümanlar

    debugPrint(
      '-> Koleksiyon: $collectionName için ${documents.length} doküman yükleniyor...',
    );

    for (final docEntry in documents.entries) {
      final docId = docEntry.key; // Örn: "kedi1"
      final docData = docEntry.value; // Dokümanın verisi

      try {
        await firestore.collection(collectionName).doc(docId).set(docData);
      } catch (e) {
        debugPrint('HATA: $collectionName/$docId yüklenemedi: $e');
      }
    }
  }

  debugPrint('--- Toplu Veri Yükleme Tamamlandı ---');
}
