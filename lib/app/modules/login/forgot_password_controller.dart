import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final supabase = Supabase.instance.client;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

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

  Future<void> sendResetEmail() async {
    if (emailController.text.isEmpty) {
      _showSnackbar('Masukkan alamat email Anda', const Color(0xff73090D));
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Masukkan alamat email yang valid', const Color(0xff73090D));
      return;
    }

    try {
      isLoading.value = true;
      await supabase.auth.resetPasswordForEmail(
        emailController.text.trim(),
      );
      _showSnackbar('Tautan reset terkirim! Cek email Anda ✓', Colors.green);
      await Future.delayed(const Duration(seconds: 2));
      
      // Hapus controller sebelum kembali
      Get.delete<ForgotPasswordController>();
      Get.back();
    } on AuthException catch (e) {
      _showSnackbar(e.message, const Color(0xff73090D));
    } catch (e) {
      _showSnackbar('Terjadi kesalahan', const Color(0xff73090D));
    } finally {
      isLoading.value = false;
    }
  }
}