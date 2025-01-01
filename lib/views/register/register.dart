import 'package:flutter/material.dart';
import 'package:vigenesia_app/services/layanan.user.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _profesiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Fungsi untuk memvalidasi email
  bool isValidEmail(String email) {
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  handleSubmit(BuildContext context) async {
    try {
      context.loaderOverlay.show();
      await Future.delayed(const Duration(milliseconds: 500));
      if (_formKey.currentState?.validate() ?? false) {
        // Validasi password dan konfirmasi password
        if (_passwordController.text != _confirmPasswordController.text) {
          _showDialog('Password Tidak Cocok',
              'Password dan konfirmasi password harus sama.');
          return;
        }
        LayananPengguna.daftar(
            nama: _namaController.text,
            email: _emailController.text,
            password: _passwordController.text,
            profesi: _profesiController.text,
            onSuccess: (message, userBaru) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Berhasil'),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            onFailed: (message) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Gagal'),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            });
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        context.loaderOverlay.hide();
      }
    }
  }

  // Fungsi untuk menampilkan dialog
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        backgroundColor: Colors.white,
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (title == 'Register Berhasil') {
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget formRegister() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Bergabunglah sekarang!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _namaController,
            label: 'Nama',
            hint: 'John Doe',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _profesiController,
            label: 'Profesi',
            hint: 'Mahasiswa',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Profesi tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'john@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!isValidEmail(value)) {
                return 'Email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '*******',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 10) {
                return 'Password minimal 10 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Konfirmasi Password',
            hint: '*******',
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => handleSubmit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[900],
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xffB6c0fd), Color(0xff6f7397)],
                        begin: Alignment.topCenter)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(32.0),
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4), // Position of the shadow
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            formRegister(),
                          ],
                        )),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  // Membuat widget TextFormField dengan validasi
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[300]),
        labelStyle: const TextStyle(color: Colors.black87),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[800]!),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black45),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Menambahkan ini
      ),
      validator: validator,
    );
  }
}
