import 'package:flutter/material.dart';

/// Fungsi untuk menampilkan Snackbar sukses
showSuccessSnackbar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white), // Warna teks
      ),
      backgroundColor: Colors.green, // Warna latar belakang untuk sukses
      behavior: SnackBarBehavior.floating, // Snackbar mengambang
      duration: const Duration(seconds: 2), // Durasi munculnya Snackbar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Sudut melengkung
      ),
    ),
  );
}

/// Fungsi untuk menampilkan Snackbar gagal
void showFailedSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white), // Warna teks
      ),
      backgroundColor: Colors.red, // Warna latar belakang untuk gagal
      behavior: SnackBarBehavior.floating, // Snackbar mengambang
      duration: const Duration(seconds: 2), // Durasi munculnya Snackbar
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Sudut melengkung
      ),
    ),
  );
}
