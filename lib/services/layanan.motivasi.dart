import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:vigenesia_app/main.dart';
import 'package:vigenesia_app/model/motivasi.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:vigenesia_app/model/motivasi.komentar.dart';
import 'package:vigenesia_app/model/user.dart';

class LayananMotivasi {
  static Future<List<MotivasiModel>> getMotivasi({int? idUser}) async {
    try {
      // Mengambil data dari API
      var rute =
          getApiRoute('motivasi${idUser == null ? '' : '?iduser=$idUser'}');
      final response = await http.get(Uri.parse(rute));
      final decoded = json.decode(response.body);
      if (decoded['status']) {
        List<dynamic> data = decoded['data'];
        var result = data.map((json) => MotivasiModel.fromJson(json)).toList();
        return result;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<dynamic> postMotivasi({
    required UserModel userdata,
    required String motivasi,
    required void Function(String msg) onSuccess,
    required void Function(String msg) onFailed,
    File? file,
  }) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(getApiRoute('motivasi')));

    request.fields['iduser'] = userdata.iduser.toString();
    request.fields['isi_motivasi'] = motivasi;

    if (file != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        'gambar', // Harus sesuai dengan nama field di server Express
        file.path,
        contentType: MediaType('image', 'jpeg'), // Sesuaikan tipe file
      );
      request.files.add(multipartFile);
    }
    var response = await (request.send());
    var responseBody = await response.stream.bytesToString();
    final decodedResponse = jsonDecode(responseBody);
    if (decodedResponse['status']) {
      onSuccess(decodedResponse['message']);
    } else {
      onFailed(decodedResponse['message']);
    }
  }

  static Future<dynamic> deleteMotivasi(
      {required int idMotivasi,
      required int idUser,
      required void Function(String msg) onSuccess,
      required void Function(String msg) onFailed}) async {
    final response = await http.delete(Uri.parse(
        getApiRoute('motivasi?idmotivasi=$idMotivasi&iduser=$idUser')));
    final decodedResponse = jsonDecode(response.body);
    if (decodedResponse['status']) {
      onSuccess(decodedResponse['message']);
    } else {
      onFailed(decodedResponse['message']);
    }
  }

  static Future<void> updatePostingan({
    required String isimotivasi,
    required String linkGambar,
    required int iduser,
    required int idmotivasi,
    required void Function(String message, MotivasiModel updatedModel) onSuccess,
    required void Function(String errorMessage) onFailed,
    XFile? gambar,
  }) async {
    try {
      var request = http.MultipartRequest(
          'PUT',
          Uri.parse(
              getApiRoute('motivasi?idmotivasi=$idmotivasi&iduser=$iduser')));
      request.fields['isi_motivasi'] = isimotivasi;
      if (gambar != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'gambar', // Harus sesuai dengan nama field di server Express
          gambar.path,
          contentType: MediaType('image', 'jpeg'), // Sesuaikan tipe file
        );
        request.files.add(multipartFile);
      } else {
        request.fields['link_gambar'] = linkGambar;
      }
      final response = await (request.send());
      final responseBody = await response.stream.bytesToString();
      final decodedBody = jsonDecode(responseBody);
      if (decodedBody['status']) {
        final motivasiTerbaru = MotivasiModel.fromJson(decodedBody['data']);
        return onSuccess(decodedBody['message'], motivasiTerbaru);
      } else {
        return onFailed(decodedBody['message']);
      }
    } catch (error) {
      return onFailed(error.toString());
    }
  }

  static Future<List<KomentarMotivasiModel>> getKomentarPostingan(
      {required int idmotivasi}) async {
    try {
      final response = await http.get(
          Uri.parse(getApiRoute('motivasi/komentar?idmotivasi=$idmotivasi')));
      final decodedResponse = jsonDecode(response.body);
      if (response.statusCode == 404) {
        return [];
      } else if (decodedResponse['status']) {
        final List<dynamic> dataMotivasi = decodedResponse['data'];
        return dataMotivasi
            .map((data) => KomentarMotivasiModel.fromJson(data))
            .toList();
      } else {
        throw Exception(
            'Terjadi kesalahan saat mengambil data komentar: ${decodedResponse['message']}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
