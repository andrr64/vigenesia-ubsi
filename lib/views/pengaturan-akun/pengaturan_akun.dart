import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vigenesia_app/model/user.dart';
import 'package:vigenesia_app/provider/user.dart';
import 'package:vigenesia_app/services/layanan.user.dart';
import 'package:vigenesia_app/views/components/snackbar.dart';

class PengaturanAkun extends HookConsumerWidget {
  const PengaturanAkun({super.key, required this.userData});
  final UserModel userData;

  dynamic renderAvatar(String avatarLink, XFile? newAvatar) {
    if (newAvatar == null) {
      return NetworkImage(avatarLink);
    } else {
      return FileImage(File(newAvatar.path));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tcNama = useTextEditingController(text: userData.nama);
    final tcEmail = useTextEditingController(text: userData.email);
    final tcProfesi = useTextEditingController(text: userData.profesi);
    final tcPasswordBaru = useTextEditingController(text: '');
    final isLoading = useState(false);
    final avatarBaru = useState<XFile?>(null);
    Future<String?> showPasswordConfirmationDialog() async {
      TextEditingController passwordController = TextEditingController();

      return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Konfirmasi Password'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Masukkan password',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Membatalkan
                },
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.black87),
                onPressed: () {
                  Navigator.of(context)
                      .pop(passwordController.text); // Mengirim password
                },
                child: Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );
    }

    Future<void> handleSimpan() async {
      final String? passwordKonfirmasi = await showPasswordConfirmationDialog();

      if (passwordKonfirmasi == null || passwordKonfirmasi.isEmpty) {
        return;
      }

      if (context.mounted) {
        context.loaderOverlay.show();
      }

      try {
        await LayananPengguna.updateData(
            email: tcEmail.text,
            nama: tcNama.text,
            avatar: avatarBaru.value,
            iduser: userData.iduser,
            confirmationPassword: passwordKonfirmasi,
            newPassword:
                tcPasswordBaru.text.isEmpty ? null : tcPasswordBaru.text,
            profesi: tcProfesi.text,
            onSuccess: (data) {
              ref
                  .watch(userProvider.notifier)
                  .updateUserData(UserModel.fromJson(data));
              if (context.mounted) {
                showSuccessSnackbar(context, 'Data berhasil disimpan');
              }
            },
            onFailed: (message) {
              showFailedSnackbar(context, message);
            }
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $e')),
          );
        }
      } finally {
        if (context.mounted) {
          context.loaderOverlay.hide();
        }
      }
    }

    Future<XFile?> pickImage() async {
      if (isLoading.value) return null;
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      return pickedImage;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.chevron_left),
        ),
      ),
      backgroundColor: Colors.white,
      body: LoaderOverlay(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundImage: renderAvatar(userData.avatarLink, avatarBaru.value),
                      backgroundColor: Colors.grey[200],
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.black87),
                      onPressed: () async {
                        final fotoProfilBaru = await pickImage();
                        if (fotoProfilBaru != null) {
                          avatarBaru.value = fotoProfilBaru;
                        }
                      },
                      child: const Text('Ubah Foto Profil'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Informasi Akun',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              const SizedBox(height: 12.5),
              TextFieldSection(label: 'Nama', controller: tcNama),
              const SizedBox(height: 12.5),
              TextFieldSection(label: 'Email', controller: tcEmail),
              const SizedBox(height: 12.5),
              TextFieldSection(label: 'Profesi', controller: tcProfesi),
              const SizedBox(height: 12.5),
              TextFieldSection(
                passwordField: true,
                label: 'Ubah Password (kosongkan jika tidak)',
                controller: tcPasswordBaru,
              ),
              const SizedBox(height: 12.5),
              FilledButton(
                  style:
                  FilledButton.styleFrom(backgroundColor: Colors.black87),
                  onPressed: () => handleSimpan(),
                  child: Text('Simpan'))
            ],
          ),
        ),
      ),)
    );
  }
}

class TextFieldSection extends StatelessWidget {
  const TextFieldSection({
    required this.label,
    required this.controller,
    this.passwordField = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool passwordField;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        TextField(
            controller: controller,
            obscureText: passwordField,
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
