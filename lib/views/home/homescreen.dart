import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vigenesia_app/model/user.dart';
import 'package:vigenesia_app/provider/motivasi.dart';
import 'package:vigenesia_app/provider/user.dart';
import 'package:vigenesia_app/services/layanan.motivasi.dart';
import 'package:vigenesia_app/views/components/card/postingan_motivasi.dart';
import 'package:vigenesia_app/views/components/card/postingan_motivasi_self.dart';
import 'package:vigenesia_app/views/components/snackbar.dart';
import 'package:vigenesia_app/views/login/login.dart';
import 'package:vigenesia_app/views/pengaturan-akun/pengaturan_akun.dart';
import 'package:vigenesia_app/views/post-motivasi/edit_motivasi.dart';
import 'package:vigenesia_app/views/post-motivasi/post_motivasi.dart';
import 'package:vigenesia_app/views/profil/profile_sendiri.dart';

Widget dHeight(double h) {
  return SizedBox(
    height: h,
  );
}

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  Widget writeSomethingInHere(BuildContext context, String avatarLink,
      UserModel userdata, WidgetRef ref) {
    final teksMotivasi = useTextEditingController();
    final focusNode = useFocusNode();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarLink),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Ketik motivasi disini...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  controller: teksMotivasi,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo, color: Colors.black87),
                    onPressed: () async {
                      focusNode.unfocus();
                      final picker = ImagePicker();
                      final pickedImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedImage == null) return;
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostMotivasi(
                                      callback: () {
                                        teksMotivasi.text = '';
                                        ref
                                            .read(motivasiProvider.notifier)
                                            .fetchMotivasi();
                                      },
                                      image: pickedImage,
                                      motivasi: teksMotivasi.text,
                                    )));
                      }
                    },
                  ),
                ],
              )),
              const SizedBox(width: 2.5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                ),
                onPressed: () async {
                  context.loaderOverlay.show();
                  if (teksMotivasi.text.isNotEmpty) {
                    try {
                      await LayananMotivasi.postMotivasi(
                          userdata: userdata,
                          motivasi: teksMotivasi.text,
                          onSuccess: (_) async {
                            await ref
                                .read(motivasiProvider.notifier)
                                .fetchMotivasi();
                            if (context.mounted) {
                              showSuccessSnackbar(
                                  context, 'Motivasi berhasil diposting');
                            }
                            teksMotivasi.clear();
                            focusNode.unfocus();
                          },
                          onFailed: (msg) {
                            if (context.mounted) {
                              showFailedSnackbar(context, msg);
                            }
                          });
                    } catch (e) {
                      if (context.mounted) {
                        showFailedSnackbar(context, 'Gagal');
                      }
                    } finally {
                      if (context.mounted) {
                        context.loaderOverlay.hide();
                      }
                    }
                  }
                },
                child: const Text(
                  "Post",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataPengguna = ref.watch(userProvider);
    final motivasiList = ref.watch(motivasiProvider);

    useEffect(() {
      if (dataPengguna != null) {
        ref.read(motivasiProvider.notifier).fetchMotivasi();
      }
      return null;
    }, [dataPengguna]);

    return LoaderOverlay(
      child: Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 16),
          child: SpeedDial(
            icon: Icons.menu,
            activeIcon: Icons.close,
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.refresh, color: Colors.white),
                label: 'Perbaharui',
                backgroundColor: Colors.black87,
                onTap: () {
                  ref.read(motivasiProvider.notifier).fetchMotivasi();
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.add, color: Colors.white),
                label: 'Post Motivasi',
                backgroundColor: Colors.black87,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PostMotivasi(callback: () {
                      ref.read(motivasiProvider.notifier).fetchMotivasi();
                    });
                  }));
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset(
            'assets/img/logo.png',
            height: 40,
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.withAlpha(50),
              height: 1.0,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 241, 242, 245),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dataPengguna != null)
                  writeSomethingInHere(
                      context, dataPengguna.avatarLink, dataPengguna, ref),
                const Text(
                  'Postingan',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                motivasiList.isEmpty
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 100),
                          child: const Text('Tidak ada postingan.'),
                        ),
                      )
                    : Column(
                        children: [
                          for (var motiv in motivasiList)
                            dataPengguna!.iduser == motiv.user.iduser
                                ? KartuPostinganSendiri(
                                    userModel: dataPengguna,
                                    model: motiv,
                                    onUpdated: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => EditMotivasi(
                                                  callbackKetikaSuksesUpdate:
                                                      () {},
                                                  motivasiLama: motiv)));
                                    },
                                    onDeleted: () async {
                                      LayananMotivasi.deleteMotivasi(
                                          idMotivasi: motiv.id,
                                          idUser: dataPengguna.iduser,
                                          onSuccess: (pesan) {
                                            ref
                                                .read(motivasiProvider.notifier)
                                                .fetchMotivasi();
                                            showSuccessSnackbar(context, pesan);
                                          },
                                          onFailed: (pesanError) {
                                            showFailedSnackbar(
                                                context, pesanError);
                                          });
                                    })
                                : KartuPostingan(model: motiv)
                        ],
                      )
              ],
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(dataPengguna!.nama),
                accountEmail: Text(dataPengguna.email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(dataPengguna.avatarLink),
                ),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HalamanProfilSendiri()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Pengaturan Akun'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PengaturanAkun(
                              userData: ref.watch(userProvider)!)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (route) => false, // Hapus semua rute sebelumnya
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
