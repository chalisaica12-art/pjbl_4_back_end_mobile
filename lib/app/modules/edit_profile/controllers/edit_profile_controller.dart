import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  String? get userId => supabase.auth.currentUser?.id;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (userId == null) return;
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId!)
          .single();
      nameController.text = response['name'] ?? '';
      emailController.text = response['email'] ?? '';
      usernameController.text = response['username'] ?? '';
      phoneController.text = response['phone'] ?? '';
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> saveProfile() async {
    if (userId == null) return;
    if (nameController.text.isEmpty) {
      Get.snackbar("Error", "Nama tidak boleh kosong",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    try {
      isLoading.value = true;
      await supabase.from('profiles').update({
        'name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
      }).eq('id', userId!);
      Get.snackbar("Sukses", "Profil berhasil diperbarui!",
          backgroundColor: const Color(0xFF8B0000), colorText: Colors.white);
      Get.back();
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}