import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vigenesia_app/main.dart';
import 'package:vigenesia_app/model/motivasi.komentar.dart';
import 'package:vigenesia_app/model/user.dart';

const Duration _TIMEOUTDURATION = Duration(seconds: 3);

class LayananPengguna {
  static Future<UserModel> getUserData(int iduser) async {
    final response = await http.get(Uri.parse(getApiRoute('user?iduser=$iduser')));
    final decodedresponse = jsonDecode(response.body);
    if (decodedresponse['status']){
      return UserModel.fromJson(decodedresponse['data']);
    }
    throw Exception('Gagal mendapatkan data pengguna');
  }

  static Future<void> login(String email, String password,
      {required void Function(String message) onFailed,
        required void Function(String message, UserModel user) onSuccess}) async {
    try {
      final response = await http
          .post(
        Uri.parse(getApiRoute('user/login')),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(_TIMEOUTDURATION);
      final decodedResponseBody = jsonDecode(response.body);
      if (decodedResponseBody['status']) {
        final UserModel user = UserModel.fromJson(decodedResponseBody['data']);
        onSuccess(decodedResponseBody['message'], user);
      } else {
        onFailed(decodedResponseBody['message']);
      }
    } catch (e) {
      if (e is TimeoutException) {
        onFailed('Gagal terhubung dengan server');
      } else {
        onFailed('Error: ${e.toString()}');
      }
    }
  }

  static Future<KomentarMotivasiModel> kirimKomentar({
    required int iduser,
    required String komentar,
    required int idmotivasi,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(getApiRoute(
            'motivasi/komentar?idmotivasi=$idmotivasi&iduser=$iduser')),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"komentar": komentar}),
      )
          .timeout(_TIMEOUTDURATION);
      final decodedResponseBody = jsonDecode(response.body);
      if (decodedResponseBody['status']) {
        final datakomentar = decodedResponseBody['data']['komentar'];
        final datauser = decodedResponseBody['data']['pengguna'];
        return KomentarMotivasiModel(
          iduser: datakomentar['iduser'],
          linkavatarPengguna: datauser['avatar_link'],
          idkomentar: datakomentar['id'],
          namapengguna: datauser['nama'],
          idmotivasi: datakomentar['idmotivasi'],
          komentar: datakomentar['komentar'],
        );
      } else {
        throw Exception(decodedResponseBody['message']);
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Gagal terhubung dengan server');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  static Future<void> updateAvatar({
    required int iduser,
    required File avatar,
    required void Function(String newAvatarURL) onSuccess,
    required void Function(String message) onFailed,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(getApiRoute('user/update/avatar?iduser=$iduser')),
      );
      var multipartFile = await http.MultipartFile.fromPath(
        'avatar',
        avatar.path,
        contentType: MediaType('image', 'jpeg'), // Sesuaikan tipe file
      );
      request.files.add(multipartFile);
      var response = await request.send().timeout(_TIMEOUTDURATION);
      var responseBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseBody);
      if (decodedResponse['status']) {
        onSuccess(decodedResponse['data']);
      } else {
        onFailed(decodedResponse['message']);
      }
    } catch (e) {
      if (e is TimeoutException) {
        onFailed('Gagal terhubung dengan server');
      } else {
        onFailed('Error: ${e.toString()}');
      }
    }
  }

  static Future<void> updateData({
    required String email,
    required int iduser,
    required String nama,
    required String confirmationPassword,
    required String profesi,
    required void Function(dynamic decodedJson) onSuccess,
    required void Function(String msg) onFailed,
    String? newPassword,
    XFile? avatar,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(getApiRoute('user/update/data?iduser=$iduser')),
      );
      request.fields.addAll({
        'email': email,
        'nama': nama,
        'password_konfirmasi': confirmationPassword,
        'profesi': profesi,
        if (newPassword != null) 'password_baru': newPassword,
      });
      if (avatar != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          avatar.path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }
      var response = await request.send().timeout(_TIMEOUTDURATION);
      if (response.statusCode == 200) {
        var decodedJson = jsonDecode(await response.stream.bytesToString());
        onSuccess(decodedJson['data']);
      } else {
        onFailed('Gagal memperbarui data. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException) {
        onFailed('Gagal terhubung dengan server');
      } else {
        onFailed('Terjadi kesalahan: $e');
      }
    }
  }

  static Future<void> daftar({
    required String nama,
    required String email,
    required String password,
    required String profesi,
    required void Function(String msg, UserModel user) onSuccess,
    required void Function(String msg) onFailed,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(getApiRoute('user/register')),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'profesi': profesi,
        }),
      )
          .timeout(_TIMEOUTDURATION);
      final decodedResponse = jsonDecode(response.body);
      final status = decodedResponse['status'];
      final message = decodedResponse['message'];
      if (status) {
        onSuccess(message, UserModel.fromJson(decodedResponse['data']));
      } else {
        onFailed(message);
      }
    } catch (e) {
      if (e is TimeoutException) {
        onFailed('Gagal terhubung dengan server');
      } else {
        onFailed('Error: ${e.toString()}');
      }
    }
  }
}