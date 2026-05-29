import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordObscured = true.obs;
  final isAgreed = false.obs;
  final isLoading = false.obs;

  final supabase = Supabase.instance.client;

  void togglePassword() => isPasswordObscured.value = !isPasswordObscured.value;
  void toggleAgreed(bool? val) => isAgreed.value = val ?? false;

  void _showSnackbar(String message, Color color) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 2),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  Future<void> handleLogin() async {
    if (!isAgreed.value) {
      _showSnackbar('Harap setujui kebijakan privasi', const Color(0xff73090D));
      return;
    }

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackbar('Mohon lengkapi semua kolom', const Color(0xff73090D));
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Masukkan alamat email yang valid', const Color(0xff73090D));
      return;
    }

    try {
      isLoading.value = true;

      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _showSnackbar('Berhasil Masuk', Colors.green);
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAllNamed('/home');

    } on AuthException catch (e) {
      String pesanError = e.message;
      if (e.message.contains('Email atau kata sandi salah')) {
        pesanError = 'Email atau kata sandi salah';
      } else if (e.message.contains('Email not confirmed')) {
        pesanError = 'Email belum dikonfirmasi';
      } else if (e.message.contains('User not found')) {
        pesanError = 'Akun tidak ditemukan';
      } else if (e.message.contains('too many requests')) {
        pesanError = 'Terlalu banyak percobaan, coba lagi nanti';
      } else if (e.message.contains('network')) {
        pesanError = 'Periksa koneksi internet kamu';
      }
      _showSnackbar(pesanError, const Color(0xff73090D));
    } finally {
      isLoading.value = false;
    }
  }
}