import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vigenesia_app/services/layanan.motivasi.dart';
import 'package:vigenesia_app/model/motivasi.dart';

class MotivasiNotifier extends StateNotifier<List<MotivasiModel>> {
  MotivasiNotifier() : super([]);

  // Fungsi untuk memuat data motivasi dari API
  Future<void> fetchMotivasi() async {
    try {
      final data = await LayananMotivasi.getMotivasi();
      state = data; // Update state dengan data baru
    } catch (e) {
      throw Exception('Gagal memuat data motivasi');
    }
  }
}

// Provider untuk MotivasiNotifier
final motivasiProvider =
    StateNotifierProvider<MotivasiNotifier, List<MotivasiModel>>(
        (ref) => MotivasiNotifier());
