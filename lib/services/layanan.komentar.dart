import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vigenesia_app/main.dart';

const int timeoutDuration = 3;

class LayananKomentar {
  static Future<void> deleteKomentar({
    required int iduser,
    required int idkomentar,
    required void Function() onSuccess,
    required void Function(String errorMessage) onFailed,
  }) async {
    try {
      final response = await http
          .delete(
        Uri.parse(getApiRoute('motivasi/komentar?iduser=$iduser&idkomentar=$idkomentar')),
      )
          .timeout(Duration(seconds: timeoutDuration));
      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse['status']) {
        return onSuccess();
      } else {
        return onFailed(decodedResponse['message']);
      }
    } on http.ClientException catch (e) {
      return onFailed('Client Error: ${e.message}');
    } on TimeoutException {
      return onFailed('Timeout'); // Menangani kondisi timeout
    } catch (e) {
      return onFailed('Unexpected Error: ${e.toString()}');
    }
  }

  static Future<void> updateKomentar({
    required int iduser,
    required int idkomentar,
    required String isikomentar,
    required void Function() onSuccess,
    required void Function(String errorMessage) onFailed,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(getApiRoute('motivasi/komentar?iduser=$iduser&idkomentar=$idkomentar')),
        body: jsonEncode({
          'isi_komentar': isikomentar, // Mengirimkan isi komentar baru
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: timeoutDuration));
      final decodedResponse = jsonDecode(response.body);
      if (decodedResponse['status']) {
        return onSuccess();
      } else {
        return onFailed(decodedResponse['message']);
      }
    } on http.ClientException catch (e) {
      return onFailed('Client Error: ${e.message}');
    } on TimeoutException {
      return onFailed('Timeout'); // Menangani kondisi timeout
    } catch (e) {
      return onFailed('Unexpected Error: ${e.toString()}');
    }
  }
}
