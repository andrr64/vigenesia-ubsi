import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vigenesia_app/model/motivasi.dart';
import 'package:vigenesia_app/provider/motivasi.dart';
import 'package:vigenesia_app/services/layanan.motivasi.dart';
import 'package:vigenesia_app/provider/user.dart';
import 'package:vigenesia_app/services/layanan.user.dart';
import 'package:vigenesia_app/util/dialog.dart';
import 'package:vigenesia_app/views/components/card/postingan_motivasi_self.dart';
import 'package:vigenesia_app/views/components/snackbar.dart';
import 'package:vigenesia_app/views/pengaturan-akun/pengaturan_akun.dart';
import 'package:vigenesia_app/views/post-motivasi/edit_motivasi.dart';

class HalamanProfilSendiri extends HookConsumerWidget {
  const HalamanProfilSendiri({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var dataPengguna = ref.watch(userProvider)!;
    var postingan = useState<List<MotivasiModel>>([]);
    var loading = useState<bool>(true);
    var listPostingan = useState<List<MotivasiModel>?>(null);

    void getMotivasi() async {
      listPostingan.value =
          await LayananMotivasi.getMotivasi(idUser: dataPengguna.iduser);
      loading.value = false;
    }

    getMotivasi();
    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.chevron_left),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 241, 242, 245),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Info
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(dataPengguna.avatarLink),
                      radius: 50,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          handleChangeImage(context, ref);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                dataPengguna.nama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                dataPengguna.profesi,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PengaturanAkun(
                                userData: ref.read(userProvider)!,
                              )));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                ),
                child: const Text(
                  'Pengaturan Akun',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              // Heading Postingan
              const Text(
                'Postingan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder(
                  valueListenable: loading,
                  builder: (context, loadingStatus, child) {
                    if (loadingStatus && listPostingan.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (listPostingan.value == null && !loadingStatus) {
                      return Center(child: const Text('Terjadi kesalahan'));
                    } else if (listPostingan.value!.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada postingan.'),
                      );
                    } else {
                      return Column(
                        children: [
                          for (final motiv in listPostingan.value!)
                            KartuPostinganSendiri(
                              userModel: dataPengguna,
                              model: motiv,
                              onUpdated: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => EditMotivasi(
                                        callbackKetikaSuksesUpdate: (){
                                          getMotivasi();
                                        },
                                        motivasiLama: motiv
                                    )
                                ));
                              },
                              onDeleted: () async {
                                await LayananMotivasi.deleteMotivasi(
                                    idMotivasi: motiv.id,
                                    idUser: dataPengguna.iduser,
                                    onSuccess: (msg) {
                                      // Panggil setState untuk memperbarui data
                                      context.loaderOverlay
                                          .show(); // Tampilkan loading
                                      LayananMotivasi.getMotivasi(
                                              idUser: dataPengguna.iduser)
                                          .then((newData) {
                                        postingan.value = newData;
                                        if (context.mounted) {
                                          ref
                                              .read(motivasiProvider.notifier)
                                              .fetchMotivasi();
                                          showSuccessSnackbar(
                                              context, 'Data berhasil dihapus');
                                          context.loaderOverlay.hide();
                                        }
                                      });
                                    },
                                    onFailed: (msg) {
                                      showFailedSnackbar(context, msg);
                                    });
                              },
                            )
                        ],
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void handleChangeImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final img = File(pickedFile.path);
        if (context.mounted) {
          showPromptDialog(context, 'Ganti Profil?', Image.file(img), () async {
            await LayananPengguna.updateAvatar(
                iduser: ref.read(userProvider)!.iduser,
                avatar: img,
                onSuccess: (newAvatarLink) {
                  ref.watch(userProvider.notifier).updateAvatar(newAvatarLink);
                },
                onFailed: (errorMessage) {
                  showFailedSnackbar(context, errorMessage);
                });
          });
        }
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }
}
