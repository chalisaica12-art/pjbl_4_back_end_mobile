import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;

  final quizList = <Map<String, dynamic>>[].obs;
  final likedItems = <String, bool>{}.obs;
  final likeCounts = <String, int>{}.obs;
  final isLoading = true.obs;
  final currentBannerPage = 0.obs;
  final selectedIndex = 0.obs;
  final userName = 'Guest'.obs;
  final userAvatar = ''.obs;

  final pageController = PageController();

  final bannerImages = [
    "assets/gambar/ban1.jpeg",
    "assets/gambar/ban2.jpeg",
    "assets/gambar/ban3.jpeg",
  ];

  String? get currentUserId => supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    fetchQuizzes();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    if (currentUserId == null) return;
    try {
      final response = await supabase
          .from('profiles')
          .select('name, avatar_url')
          .eq('id', currentUserId!)
          .single();
      userName.value = response['name'] ?? 'Guest';
      userAvatar.value = response['avatar_url'] ?? '';
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

      quizList.value = List<Map<String, dynamic>>.from(response);

      // Init like counts
      for (var quiz in quizList) {
        likeCounts[quiz['id'].toString()] = (quiz['rating'] as num).toInt();
      }

      // Fetch likes user kalau sudah login
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Login Required'),
          content: const Text('Please login to like this quiz'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
            .update({'rating': currentCount - 1})
            .eq('id', quizId);
      } else {
        await supabase.from('quiz_likes').insert({
          'quiz_id': quizId,
          'user_id': currentUserId!,
        });
        likedItems[quizId] = true;
        likeCounts[quizId] = currentCount + 1;
        await supabase
            .from('quizzes')
            .update({'rating': currentCount + 1})
            .eq('id', quizId);
      }
      likedItems.refresh();
      likeCounts.refresh();
    } catch (e) {
      print('Error toggle like: $e');
    }
  }

  bool isUnlocked(int orderNumber) {
    if (orderNumber == 1) return true;
    // Cek apakah quiz sebelumnya sudah selesai
    // Untuk sekarang, hanya yang pertama yang terbuka
    return false;
  }

  void onQuizTap(Map<String, dynamic> quiz) {
    final isLocked = quiz['is_locked'] ?? true;
    if (isLocked) {
      Get.snackbar(
        '',
        'Selesaikan quiz sebelumnya terlebih dahulu!',
        backgroundColor: const Color(0xFF73090D),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.zero,
        borderRadius: 0,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
        duration: const Duration(seconds: 2),
      );
      return;
    }
    if (currentUserId == null) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Login Required'),
          content: const Text('Please login to play this quiz'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
    Get.toNamed('/detail-kuis', arguments: quiz);
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