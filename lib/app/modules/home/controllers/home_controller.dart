import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/controllers/profile_controller.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  final quizList = <Map<String, dynamic>>[].obs;
  final likedItems = <String, bool>{}.obs;
  final likeCounts = <String, int>{}.obs;
  final isLoading = true.obs;
  final currentBannerPage = 0.obs;
  final selectedIndex = 0.obs;
  final userName = 'Tamu'.obs;
  final userAvatar = ''.obs;
  final userStars = 0.obs;

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

  Future<void> fetchQuizzes() async {
    try {
      isLoading.value = true;
      final response = await supabase
          .from('quizzes')
          .select()
          .eq('category', 'journey')
          .order('order_number', ascending: true);

      final rawQuizzes = List<Map<String, dynamic>>.from(response);

      final filteredQuizzes = rawQuizzes.where((quiz) {
        final orderNum = quiz['order_number'] as int? ?? 0;
        return orderNum == 1 || orderNum == 2 || orderNum == 3;
      }).toList();

      quizList.value = filteredQuizzes;

      for (var quiz in filteredQuizzes) {
        print('=== Era ${quiz['order_number']} ===');
        print('image value: "${quiz['image']}"');
        print('image type: ${quiz['image'].runtimeType}');
      }

      for (var quiz in quizList) {
        likeCounts[quiz['id'].toString()] = (quiz['rating'] as num).toInt();
      }

      if (currentUserId != null) {
        final likes = await supabase
            .from('quiz_likes')
            .select('quiz_id')
            .eq('user_id', currentUserId!);
        for (var like in likes) {
          likedItems[like['quiz_id']] = true;
        }
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleLike(String quizId) async {
    if (currentUserId == null) {
      Get.dialog(
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Login Required'),
          content: const Text('Please login to like this quiz'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/login');
              },
              child: const Text('Login',
                  style: TextStyle(color: Color(0xFF73090D))),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final isLiked = likedItems[quizId] ?? false;
      final currentCount = likeCounts[quizId] ?? 0;

      if (isLiked) {
        await supabase
            .from('quiz_likes')
            .delete()
            .eq('quiz_id', quizId)
            .eq('user_id', currentUserId!);
        likedItems[quizId] = false;
        likeCounts[quizId] = currentCount - 1;
        await supabase
            .from('quizzes')
            .update({'rating': currentCount - 1}).eq('id', quizId);
      } else {
        await supabase.from('quiz_likes').insert({
          'quiz_id': quizId,
          'user_id': currentUserId!,
        });
        likedItems[quizId] = true;
        likeCounts[quizId] = currentCount + 1;
        await supabase
            .from('quizzes')
            .update({'rating': currentCount + 1}).eq('id', quizId);
      }
      likedItems.refresh();
      likeCounts.refresh();
    } catch (e) {
      print('Error toggle like: $e');
    }
  }

  bool isUnlocked(int orderNumber) {
    if (orderNumber == 1) return true;
    if (isGuest) return false;
    return false;
  }

  void onQuizTap(Map<String, dynamic> quiz) {
    final orderNum = quiz['order_number'] as int? ?? 1;
    final isLocked = !isUnlocked(orderNum);

    if (isLocked && orderNum > 1 && isGuest) {
      Get.dialog(
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Login Diperlukan'),
          content: const Text(
              'Kamu harus login untuk memainkan era ini dan menyimpan skor!'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child:
                  const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed('/login');
              },
              child: const Text('Login',
                  style: TextStyle(color: Color(0xFF73090D))),
            ),
          ],
        ),
      );
      return;
    }

    // ✅ DIALOG UNTUK ERA TERKUNCI (bukan snackbar)
    if (isLocked) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Era Terkunci',
            style: TextStyle(
              color: Color(0xFF73090D),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Selesaikan era sebelumnya terlebih dahulu!',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF73090D)),
              ),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Login Diperlukan'),
              content: const Text('Kamu harus login untuk melihat profil!'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal',
                      style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/login');
                  },
                  child: const Text('Login',
                      style: TextStyle(color: Color(0xFF73090D))),
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