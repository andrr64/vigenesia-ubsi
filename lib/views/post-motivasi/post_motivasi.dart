import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vigenesia_app/services/layanan.motivasi.dart';
import 'package:vigenesia_app/provider/motivasi.dart';
import 'package:vigenesia_app/provider/user.dart';
import 'package:vigenesia_app/views/components/snackbar.dart';

class PostMotivasi extends HookConsumerWidget {
  const PostMotivasi(
      {super.key, required this.callback, this.image, this.motivasi});
  final String? motivasi;
  final XFile? image;
  final void Function() callback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final imageState = useState<XFile?>(null);
    final isLoading = useState(false); // Tambahkan state loading

    useEffect(() {
      if (image != null) {
        imageState.value = image;
      }
      if (motivasi != null) {
        textController.text = motivasi!;
      }
      return null;
    }, []);

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
            'Post Motivasi',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(15, 0, 0, 0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: imageState.value != null
                          ? (kIsWeb
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageState.value!.path,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(imageState.value!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ))
                          : Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  ),
                  onPressed: isLoading.value
                      ? null // Nonaktifkan tombol saat loading
                      : () async {
                          if (textController.text.isNotEmpty) {
                            try {
                              isLoading.value = true;
                              context.loaderOverlay.show();
      
                              final teks = textController.text;
                              await LayananMotivasi.postMotivasi(
                                  motivasi: teks,
                                  userdata: ref.read(userProvider)!,
                                  file: imageState.value == null
                                      ? null
                                      : File(imageState.value!.path),
                                  onFailed: (msg) {
                                    showFailedSnackbar(
                                        context, 'Gagal: Terjadi kesalahan');
                                  },
                                  onSuccess: (msg) {
                                    imageState.value = null;
                                    textController.text = '';
                                    ref
                                        .read(motivasiProvider.notifier)
                                        .fetchMotivasi();
                                    showSuccessSnackbar(context, msg);
                                  });
                            } finally {
                              context.loaderOverlay.hide();
                              isLoading.value = false;
                            }
                          }
                        },
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isLoading,
                    builder: (context, loading, child) {
                      return Text(
                        loading ? "Tunggu sebentar..." : "Post",
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
