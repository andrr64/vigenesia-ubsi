import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List?> downloadImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes; // Mengembalikan gambar dalam bentuk bytes
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<void> checkImageUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print("Gambar berhasil diunduh");
    } else {
      print("Gagal mengunduh gambar: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
