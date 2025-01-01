import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vigenesia_app/model/motivasi.dart';
import 'package:vigenesia_app/services/layanan.motivasi.dart';
import 'package:vigenesia_app/provider/motivasi.dart';
import 'package:vigenesia_app/provider/user.dart';
import 'package:vigenesia_app/views/components/snackbar.dart';
import 'package:vigenesia_app/views/home/homescreen.dart';

class EditMotivasi extends HookConsumerWidget {
  const EditMotivasi(
      {super.key, required this.callbackKetikaSuksesUpdate, required this.motivasiLama});
  final MotivasiModel motivasiLama;

  final void Function() callbackKetikaSuksesUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final imageState = useState<XFile?>(null);
    final isLoading = useState(false); // Tambahkan state loading
    final linkGambar = useState<String>(motivasiLama.linkGambar);
    final isiMotivasi = useState<String>(motivasiLama.isiMotivasi);

    useEffect(() {
      textController.text = isiMotivasi.value;
      return null;
    }, []);

    Future<void> handleUpdate() async {
      isLoading.value = true;
      context.loaderOverlay.show();
      isiMotivasi.value = textController.text;
      await LayananMotivasi.updatePostingan(
          isimotivasi: isiMotivasi.value,
          linkGambar: linkGambar.value,
          iduser: ref.watch(userProvider)!.iduser,
          gambar: imageState.value,
          idmotivasi: motivasiLama.id,
          onSuccess: (msg, data) async{
            await ref.watch(motivasiProvider.notifier).fetchMotivasi();
            if (context.mounted){
              Navigator.pop(context);
              showSuccessSnackbar(context, 'Data berhasil diperbaharui');
            }
            callbackKetikaSuksesUpdate();
          },
          onFailed: (msg) {
            showFailedSnackbar(context, msg);
          });
      if (context.mounted){
        context.loaderOverlay.hide();
      }
      isLoading.value = false;
    }

    Future<void> pickImage() async {
      if (isLoading.value) return; // Cegah pengambilan gambar saat loading
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        imageState.value = pickedImage;
      }
    }

    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Update Motivasi',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          leading: GestureDetector(
            onTap: () {
              if (!isLoading.value) Navigator.pop(context);
            },
            child: const Icon(Icons.chevron_left),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto (opsional)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: Container(
                        width: 256,
                        height: 256,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(15, 0, 0, 0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: imageState.value == null
                            ? linkGambar.value.isNotEmpty
                                ? Image.network(
                                    linkGambar.value,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Center(
                                    child: Icon(Icons.add),
                                  )
                            : Image.file(
                                File(imageState
                                    .value!.path), // File gambar lokal
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )),
                  ),
                ),
                dHeight(5),
                imageState.value != null || linkGambar.value.isNotEmpty
                    ? Center(
                        child: FilledButton(
                            onPressed: () {
                              imageState.value = null;
                              linkGambar.value = '';
                            },
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.black),
                            child: Text('Hapus Avatar')),
                      )
                    : SizedBox(),
                Center(
                  child: FilledButton(
                      onPressed: () {
                        imageState.value = null;
                        linkGambar.value = motivasiLama.linkGambar;
                        isiMotivasi.value = motivasiLama.isiMotivasi;
                        textController.text = isiMotivasi.value;
                      },
                      child: Text('Kembalikan')),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.reviews),
                    SizedBox(width: 2),
                    Text(
                      'Motivasi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textController,
                  enabled: !isLoading.value, // Nonaktifkan saat loading
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'Tulis motivasi Anda di sini...',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                  ),
                  onPressed: isLoading.value
                      ? null // Nonaktifkan tombol saat loading
                      : handleUpdate,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isLoading,
                    builder: (context, loading, child) {
                      return Text(
                        loading ? "Tunggu sebentar..." : "Update",
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
