import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  final quizList = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final currentBannerPage = 0.obs;
  final selectedIndex = 0.obs;
  final userName = 'Tamu'.obs;
  final userAvatar = ''.obs;
  final userStars = 0.obs;

  // ✅ Map era_id -> true/false (apakah semua materi di era itu selesai)
  final eraCompletionMap = <String, bool>{}.obs;

  final pageController = PageController();

  final bannerImages = [
    "assets/gambar/ban1.jpeg",
    "assets/gambar/ban2.jpeg",
    "assets/gambar/ban3.jpeg",
  ];

  String? get currentUserId => supabase.auth.currentUser?.id;
  bool get isGuest => currentUserId == null;

  @override
  void onInit() {
    super.onInit();
    fetchQuizzes();
    fetchUserProfile();

    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      ever(profileCtrl.activeAvatarId, (_) {
        userAvatar.value = profileCtrl.activeAvatarImage;
      });
      userAvatar.value = profileCtrl.activeAvatarImage;
    }
  }

  Future<void> fetchUserProfile() async {
    if (currentUserId == null) return;
    try {
      final response = await supabase
          .from('profiles')
          .select('name, active_avatar_id, stars')
          .eq('id', currentUserId!)
          .single();

      userName.value = response['name'] ?? 'Tamu';
      userStars.value = response['stars'] ?? 0;

      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController());
      }
      final profileCtrl = Get.find<ProfileController>();

      int retry = 0;
      while (profileCtrl.avatars.isEmpty && retry < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        retry++;
      }

      userAvatar.value = profileCtrl.activeAvatarImage;
      ever(profileCtrl.activeAvatarId, (_) {
        userAvatar.value = profileCtrl.activeAvatarImage;
      });
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  // ✅ Cek apakah semua materi di tiap era sudah selesai
  Future<void> _fetchEraCompletion(List<Map<String, dynamic>> eras) async {
    if (currentUserId == null) return;

    try {
      final newMap = <String, bool>{};

      for (final era in eras) {
        final eraId = era['id']?.toString() ?? '';
        if (eraId.isEmpty) continue;

        // Hitung total materi di era ini
        final materiResponse = await supabase
            .from('materials')
            .select('id')
            .eq('era_id', eraId);
        final totalMateri = (materiResponse as List).length;

        if (totalMateri == 0) {
          newMap[eraId] = false;
          continue;
        }

        // Hitung materi yang sudah selesai user di era ini
        final progressResponse = await supabase
            .from('user_progress')
            .select('chapter_index')
            .eq('user_id', currentUserId!)
            .eq('era_id', eraId)
            .eq('completed', true);
        final completedCount = (progressResponse as List).length;

        newMap[eraId] = completedCount >= totalMateri;
        print('Era $eraId: $completedCount/$totalMateri selesai');
      }

      eraCompletionMap.value = newMap;
    } catch (e) {
      print('Error fetching era completion: $e');
    }
  }

  Future<void> fetchQuizzes() async {
    try {
      isLoading.value = true;

      final response = await supabase
          .from('quizzes')
          .select()
          .order('order_number', ascending: true);

      final rawQuizzes = List<Map<String, dynamic>>.from(response);

      // Tampilkan 3 era pertama
      final filteredQuizzes = rawQuizzes.where((quiz) {
        final orderNum = quiz['order_number'] as int? ?? 0;
        return orderNum >= 1 && orderNum <= 3;
      }).toList();

      quizList.value = filteredQuizzes;

      // ✅ Setelah dapat data era, fetch completion status
      await _fetchEraCompletion(filteredQuizzes);
    } catch (e) {
      print('Error fetching quizzes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Era 1 selalu unlock
  // Era N unlock kalau semua materi di era N-1 sudah selesai
  bool isUnlocked(int orderNumber) {
    if (orderNumber == 1) return true;
    if (isGuest) return false;

    // Cari era sebelumnya
    final prevEra = quizList.firstWhereOrNull(
      (q) => (q['order_number'] as int? ?? 0) == orderNumber - 1,
    );
    if (prevEra == null) return false;

    final prevEraId = prevEra['id']?.toString() ?? '';
    return eraCompletionMap[prevEraId] == true;
  }

  void onQuizTap(Map<String, dynamic> quiz) {
    final orderNum = quiz['order_number'] as int? ?? 1;
    final isLocked = !isUnlocked(orderNum);

    if (isLocked && isGuest) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Login Diperlukan'),
          content: const Text('Kamu harus login untuk memainkan era ini dan menyimpan skor!'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/login');
              },
              child: const Text('Login', style: TextStyle(color: Color(0xFF73090D))),
            ),
          ],
        ),
      );
      return;
    }

    if (isLocked) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Era Terkunci',
            style: TextStyle(color: Color(0xFF73090D), fontWeight: FontWeight.bold),
          ),
          content: const Text('Selesaikan semua materi era sebelumnya terlebih dahulu!'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF73090D))),
            ),
          ],
        ),
        barrierDismissible: true,
      );
      return;
    }

    Get.toNamed('/quiz-detail', arguments: quiz);
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        break;
      case 1:
        Get.toNamed('/leaderboard');
        break;
      case 2:
        if (isGuest) {
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Login Diperlukan'),
              content: const Text('Kamu harus login untuk melihat profil!'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/login');
                  },
                  child: const Text('Login', style: TextStyle(color: Color(0xFF73090D))),
                ),
              ],
            ),
          );
          return;
        }
        Get.toNamed('/profile');
        break;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}