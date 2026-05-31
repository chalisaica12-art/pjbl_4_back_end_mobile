import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../home/controllers/home_controller.dart';

class EditProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  String? get userId => supabase.auth.currentUser?.id;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  var isLoading = false.obs;
  var activeAvatarImage = ''.obs; // ✅ TAMBAHAN

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    if (userId == null) {
      print("UserId null, tidak bisa fetch profile");
      return;
    }

    try {
      print("Fetching profile for user: $userId");
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId!)
          .maybeSingle();

      if (response != null) {
        nameController.text = response['name'] ?? '';
        emailController.text = response['email'] ?? '';
        phoneController.text = response['phone'] ?? '';
        print("Profile loaded: Nama=${nameController.text}, Email=${emailController.text}");
      } else {
        print("Profile not found for user: $userId");
      }

      // ✅ TAMBAHAN: load avatar image dari ProfileController
      if (Get.isRegistered<ProfileController>()) {
        activeAvatarImage.value = Get.find<ProfileController>().activeAvatarImage;
      }
    } catch (e) {
      print('Error fetch profile: $e');
      Get.snackbar("Error", "Gagal memuat profil: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveProfile() async {
    if (userId == null) {
      Get.snackbar("Error", "User tidak ditemukan",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (nameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Nama tidak boleh kosong",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      print("Saving profile for user: $userId");
      print("Data: name=${nameController.text.trim()}, phone=${phoneController.text.trim()}");

      await supabase.from('profiles').update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      }).eq('id', userId!);

      Get.snackbar(
        "Sukses",
        "Profil berhasil diperbarui!",
        backgroundColor: const Color(0xFFFDE7E4),
        colorText: const Color.fromARGB(255, 0, 0, 0),
      );

      await Get.offNamed('/profile');

      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().fetchProfile();
      }

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchUserProfile();
      }
    } catch (e) {
      print('Error save profile: $e');
      Get.snackbar("Gagal", "Terjadi kesalahan: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}