import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseIslemler {
  final CollectionReference binalar =
      FirebaseFirestore.instance.collection('Bina Konumlari');



  Future<List<Map<String, dynamic>>> hasarEkle() async {
    var snapshots = await binalar.snapshots().first;

    List<Map<String, dynamic>> resultList = snapshots.docs.map((doc) {
      List<double> konumTurDonusumDizi = [];
      List<dynamic> konumDiziString = doc['konum'].split(',');
      for (var element in konumDiziString) {
        konumTurDonusumDizi.add(double.parse(element));
      }
      return {
        'hasarDurumu': doc['hasarDurumu'] ?? '',
        'konum': konumTurDonusumDizi ?? '',
      };
    }).toList();

    return resultList;
  }

  Future<void> veriEkle({
    required String binaAdi,
    required String hasarDurumu,
    required String konum,
  }) async {
    try {
      Map<String, dynamic> _eklenecekUser = {
        'binaAdi': binaAdi,
        'hasarDurumu': hasarDurumu,
        'konum': konum,
      };

      await binalar.add(_eklenecekUser);
      print('başarili');
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }
}
