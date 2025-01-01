import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:vigenesia_app/services/layanan.user.dart';
import 'package:vigenesia_app/provider/user.dart';
import 'package:vigenesia_app/views/home/homescreen.dart';
import 'package:vigenesia_app/views/register/register.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  handleSubmit() async {
    try {
      context.loaderOverlay.show();
      await LayananPengguna.login(_emailController.text, _passwordController.text,
          onSuccess: (msg, user) {
        ref.read(userProvider.notifier).loginWithModel(user);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }, onFailed: (msg) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Gagal'),
              content: Text(msg),
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
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Login Gagal'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        context.loaderOverlay.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget formLogin() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/img/logo.png'),
          const SizedBox(
            height: 50,
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
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
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleSubmit, // panggil handleSubmit
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>Register()),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 100,
          )
        ],
      );
    }

    Widget gambarAnime1() {
      return Positioned(
          bottom: 0,
          left: 25,
          child: Image.asset(
            'assets/img/login_anime_1.png',
            height: MediaQuery.of(context).size.height * 0.225,
          ));
    }

    Widget gambarAnime2() {
      return Positioned(
          bottom: 0,
          right: 25,
          child: Image.asset(
            'assets/img/login_anime_2.png',
            height: MediaQuery.of(context).size.height * 0.225,
          ));
    }

    return Scaffold(
        body: LoaderOverlay(child:  SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xffB6C0FD), Color(0xff6D7397)],
                          begin: Alignment.topCenter)),
                  child: formLogin()),
              gambarAnime1(),
              gambarAnime2()
            ],
          ),
        ))
    );
  }

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
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      validator: validator,
    );
  }
}
