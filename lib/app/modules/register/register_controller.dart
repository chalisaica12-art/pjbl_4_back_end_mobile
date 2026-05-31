import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController extends GetxController {
  // Step 1
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();

  // Step 2
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordObscured = true.obs;
  final isConfirmPasswordObscured = true.obs;
  final isAgreed = false.obs;
  final isLoading = false.obs;

  final supabase = Supabase.instance.client;

  void togglePassword() => isPasswordObscured.value = !isPasswordObscured.value;
  void toggleConfirmPassword() => isConfirmPasswordObscured.value = !isConfirmPasswordObscured.value;
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
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  void handleNext() {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      _showSnackbar('Mohon lengkapi semua kolom', const Color(0xff73090D));
      return;
    }
    Get.toNamed('/register-step2');
  }

  Future<void> handleRegister() async {
    if (!isAgreed.value) {
      _showSnackbar('Harap setujui kebijakan privasi', const Color(0xff73090D));
      return;
    }

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackbar('Mohon lengkapi semua kolom', const Color(0xff73090D));
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Masukkan alamat email yang valid', const Color(0xff73090D));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackbar('Kata sandi tidak cocok', const Color(0xff73090D));
      return;
    }

    if (passwordController.text.length < 6) {
      _showSnackbar('Kata sandi minimal 6 karakter', const Color(0xff73090D));
      return;
    }

    try {
      isLoading.value = true;

      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        // ✅ INSERT KE PROFILES DENGAN AVATAR KOSONG (NULL)
        await supabase.from('profiles').upsert({
          'id': response.user!.id,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'username': usernameController.text.trim().isEmpty 
              ? nameController.text.trim() 
              : usernameController.text.trim(),
          'stars': 0,
          'level': 1,
          'xp': 0,
          'active_avatar_id': null,  // ✅ KOSONG! TIDAK PAKAI AVATAR DEFAULT
          'unlocked_avatar_ids': [],  // ✅ BELUM PUNYA AVATAR APAPUN
        }, onConflict: 'id');

        _showSnackbar('Pendaftaran Berhasil', Colors.green);
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed('/home');
      } else {
        _showSnackbar('Pendaftaran gagal, coba lagi', const Color(0xff73090D));
      }
    } on AuthException catch (e) {
      _showSnackbar(e.message, const Color(0xff73090D));
    } catch (e) {
      print('ERROR: $e');
      _showSnackbar('Terjadi kesalahan', const Color(0xff73090D));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}