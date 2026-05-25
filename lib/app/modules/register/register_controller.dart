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

  // Validasi step 1 lalu pindah ke step 2
  void handleNext() {
    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showSnackbar('Please fill in all fields', const Color(0xff73090D));
      return;
    }
    Get.toNamed('/register-step2');
  }

  // Proses register di step 2
  Future<void> handleRegister() async {
    if (!isAgreed.value) {
      _showSnackbar('Please agree with privacy policy', const Color(0xff73090D));
      return;
    }

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackbar('Please fill in all fields', const Color(0xff73090D));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackbar('Password does not match', const Color(0xff73090D));
      return;
    }

    if (passwordController.text.length < 6) {
      _showSnackbar('Password minimum 6 characters', const Color(0xff73090D));
      return;
    }

    try {
      isLoading.value = true;

      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        await supabase.from('profiles').insert({
          'id': response.user!.id,
          'name': nameController.text.trim(),
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
        });

        _showSnackbar('Register Successful! ✓', Colors.green);
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed('/home');
      }
    } on AuthException catch (e) {
      _showSnackbar(e.message, const Color(0xff73090D));
    } catch (e) {
      _showSnackbar('Something went wrong', const Color(0xff73090D));
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