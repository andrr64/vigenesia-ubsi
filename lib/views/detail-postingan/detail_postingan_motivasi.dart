import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vigenesia_app/model/motivasi.dart';
import 'package:vigenesia_app/model/motivasi.komentar.dart';
import 'package:vigenesia_app/model/user.dart';
import 'package:vigenesia_app/provider/user.dart';
import 'package:vigenesia_app/services/layanan.komentar.dart';
import 'package:vigenesia_app/services/layanan.motivasi.dart';
import 'package:vigenesia_app/services/layanan.user.dart';
import 'package:vigenesia_app/views/components/snackbar.dart';
import 'package:vigenesia_app/views/profil/profile_orang_lain.dart';
import 'package:vigenesia_app/views/profil/profile_sendiri.dart';

class PostinganMotivasi extends HookConsumerWidget {
  const PostinganMotivasi({super.key, required this.motivasi});

  final MotivasiModel motivasi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final komentarPostingan = useState<List<KomentarMotivasiModel>>([]);
    final isLoading = useState(true);
    final kontrolerFieldKomentar = useTextEditingController();
    final userData = ref.watch(userProvider)!;
    Future<void> fetchKomentarPostingan() async {
      try {
        final data =
            await LayananMotivasi.getKomentarPostingan(idmotivasi: motivasi.id);
        komentarPostingan.value = data;
      } catch (error) {
        // Handle error
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      fetchKomentarPostingan();
      return null;
    }, []);

    Future<void> handleAddKomentar() async {
      final komentar = kontrolerFieldKomentar.text;
      if (komentar.isEmpty) return;
      context.loaderOverlay.show();
      try {
        await LayananPengguna.kirimKomentar(
          iduser: ref.read(userProvider)!.iduser,
          komentar: komentar,
          idmotivasi: motivasi.id,
        );
        kontrolerFieldKomentar.clear();
        final updatedKomentar = await LayananMotivasi.getKomentarPostingan(
          idmotivasi: motivasi.id,
        );
        komentarPostingan.value = updatedKomentar;
        showSuccessSnackbar(context, 'Komentar berhasil ditambahkan');
      } catch (error) {
        if (context.mounted) {
          showFailedSnackbar(context, error.toString());
        }
      } finally {
        if (context.mounted) {
          context.loaderOverlay.hide();
        }
      }
    }

    Widget renderImage() {
      if (motivasi.linkGambar.isEmpty) {
        return const SizedBox();
      }
      return Center(
        child: Image.network(
          motivasi.linkGambar,
          height: 256,
        ),
      );
    }

    List<Widget> renderKomentar() {
      if (komentarPostingan.value.isNotEmpty) {
        return komentarPostingan.value.map((komentar) {
          if (komentar.iduser == userData.iduser) {
            return KomentarSendiri(
                userdata: userData,
                onUpdated: (komentarBaru) async{
                  context.loaderOverlay.show();
                  try {
                    await LayananKomentar.updateKomentar(
                        iduser: userData.iduser,
                        idkomentar: komentar.idkomentar,
                        isikomentar: komentarBaru,
                        onSuccess: () async{
                          await fetchKomentarPostingan();
                          showSuccessSnackbar(context, 'Data berhasil diperbaharui');
                        }, onFailed: (errorMsg){
                          throw Exception(errorMsg);
                    });
                  } catch (e){
                    showFailedSnackbar(context, e.toString());
                  } finally {
                    if (context.mounted){
                      context.loaderOverlay.hide();
                    }
                  }
                },
                onDelete: () async {
                  await LayananKomentar.deleteKomentar(
                      iduser: userData.iduser,
                      idkomentar: komentar.idkomentar,
                      onSuccess: () {
                        showSuccessSnackbar(
                            context, 'Komentar berhasil dihapus');
                        fetchKomentarPostingan();
                      },
                      onFailed: (errorMessage) {});
                },
                komentar: komentar);
          }
          return KomentarOranglain(komentar: komentar);
        }).toList();
      } else {
        return [Center(child: Text('Tidak ada komentar.'))];
      }
    }

    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 241, 242, 245),
        appBar: AppBar(
          title: const Text('Postingan'),
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.chevron_left),
          ),
        ),
        body: isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PeopleProfilPage(
                                      dataPengguna: motivasi.user),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(motivasi.user.avatarLink),
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      motivasi.user.nama,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      motivasi.user.profesi,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(motivasi.isiMotivasi),
                          const SizedBox(height: 10),
                          renderImage(),
                          const SizedBox(height: 10),
                          Text(
                            motivasi.getWaktuUntukPostingan(),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tulis Komentar',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              TextField(
                                controller: kontrolerFieldKomentar,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText:
                                      'Tulis Komentar', // Placeholder text
                                  filled: true, // Aktifkan background color
                                  fillColor: Colors.grey[
                                      200], // Warna abu-abu untuk background
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Radius melingkar
                                    borderSide: BorderSide
                                        .none, // Hilangkan garis border
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 10), // Padding dalam TextField
                                ),
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                ),
                                onPressed: handleAddKomentar,
                                child: const Text(
                                  'Kirim',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 25),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          const Text(
                            'Komentar',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          ...renderKomentar(),
                          const SizedBox(height: 45),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

class KomentarSendiri extends HookConsumerWidget {
  const KomentarSendiri(
      {super.key,
      required this.userdata,
      required this.komentar,
      required this.onDelete,
      required this.onUpdated});
  final UserModel userdata;
  final KomentarMotivasiModel komentar;
  final void Function() onDelete;
  final void Function(String komentarBaru) onUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEdit = useState(false);
    final komentarKontroller = useTextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xfff2f5f3),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(komentar.linkavatarPengguna),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 10),
            Container(
                child: ValueListenableBuilder(
              valueListenable: isEdit,
              builder: (context, edit, child) {
                if (!edit) {
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: Text(
                            komentar.namapengguna,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () async {
                            try {
                              final data = await LayananPengguna.getUserData(
                                  komentar.iduser);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => HalamanProfilSendiri()),
                              );
                            } catch (e) {
                              showFailedSnackbar(context, e.toString());
                            }
                          },
                        ),
                        Text(
                          komentar.komentar,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                } else {
                  komentarKontroller.text = komentar.komentar;
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: komentarKontroller,
                          decoration: const InputDecoration(
                            hintText: 'Edit Komentar',
                          ),
                          maxLines: 3,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                isEdit.value = false; // Batalkan edit
                              },
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final komentarBaru =
                                    komentarKontroller.text.trim();
                                if (komentarBaru.isNotEmpty) {
                                  onUpdated(
                                      komentarBaru); // Panggil fungsi pembaruan
                                  isEdit.value = false; // Selesai edit
                                } else {
                                  showFailedSnackbar(
                                      context, 'Komentar tidak boleh kosong!');
                                }
                              },
                              child: const Text('Simpan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            )),
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                if (value == 'update') {
                  isEdit.value = true;
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'update',
                  child: Text('Update'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}

class KomentarOranglain extends StatelessWidget {
  const KomentarOranglain({super.key, required this.komentar});
  final KomentarMotivasiModel komentar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xfff2f5f3),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(komentar.linkavatarPengguna),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Text(
                      komentar.namapengguna,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () async {
                      try {
                        final data =
                            await LayananPengguna.getUserData(komentar.iduser);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    PeopleProfilPage(dataPengguna: data)));
                      } catch (e) {
                        showFailedSnackbar(context, e.toString());
                      }
                    },
                  ),
                  Text(
                    komentar.komentar,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
