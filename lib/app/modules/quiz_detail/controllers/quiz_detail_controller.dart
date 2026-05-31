import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/home_controller.dart';

class QuizDetailController extends GetxController {
  final supabase = Supabase.instance.client;

  var progress = 0.0.obs;
  var currentScore = 0.obs;
  var totalQuestions = 10.obs;
  var isLoggedIn = false.obs;
  var chapters = <Map<String, dynamic>>[].obs;

  bool get userLoggedIn => supabase.auth.currentUser != null;
  String? get userId => supabase.auth.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    isLoggedIn.value = userLoggedIn;
    final quizData = Get.arguments as Map<String, dynamic>;
    loadChapters(quizData);
  }

  void loadChapters(Map<String, dynamic> quizData) {
    chapters.value = [
      {'title': 'Meganthropus Paleojavanicus', 'completed': false, 'locked': false},
      {'title': 'Pithecanthropus Erectus', 'completed': false, 'locked': true},
      {'title': 'Jenis-Jenis Manusia Cerdas', 'completed': false, 'locked': true},
      {'title': 'Masa Berburu dan Meramu Tingkat Awal', 'completed': false, 'locked': true},
      {'title': 'Masa Berburu Tingkat Lanjut', 'completed': false, 'locked': true},
      {'title': 'Masa Bercocok Tanam', 'completed': false, 'locked': true},
      {'title': 'Zaman Batu (Paleolitikum & Mesolitikum)', 'completed': false, 'locked': true},
      {'title': 'Zaman Batu Muda (Neolitikum)', 'completed': false, 'locked': true},
      {'title': 'Zaman Megalitikum (Batu Besar)', 'completed': false, 'locked': true},
      {'title': 'Zaman Logam (Perundagian)', 'completed': false, 'locked': true},
    ];

    if (userLoggedIn) {
      _loadProgressFromDB(quizData['id']?.toString() ?? '');
    }
    _updateProgress();
  }

  Future<void> _loadProgressFromDB(String eraId) async {
    if (userId == null || eraId.isEmpty) return;
    try {
      final response = await supabase
          .from('user_progress')
          .select('chapter_index, completed')
          .eq('user_id', userId!)
          .eq('era_id', eraId);
      final List<dynamic> progressData = response as List<dynamic>;
      for (final item in progressData) {
        final int idx = item['chapter_index'] ?? -1;
        final bool completed = item['completed'] ?? false;
        if (idx >= 0 && idx < chapters.length && completed) {
          chapters[idx]['completed'] = true;
          chapters[idx]['locked'] = false;
          if (idx + 1 < chapters.length) {
            chapters[idx + 1]['locked'] = false;
          }
        }
      }
      chapters.refresh();
      _updateProgress();
    } catch (e) {
      print('Load progress error (ignored): $e');
    }
  }

  void _updateProgress() {
    int completedCount = chapters.where((c) => c['completed'] == true).length;
    progress.value = chapters.isEmpty ? 0 : completedCount / chapters.length;
    currentScore.value = completedCount * 10;
    totalQuestions.value = chapters.length * 5;
  }

  // ✅ DIPERBAIKI: Materi 2 terbuka untuk user login meskipun materi 1 belum selesai
  bool isChapterAccessible(int index) {
    // Materi 1 selalu terbuka
    if (index == 0) return true;
    
    // Guest: hanya bisa materi 1
    if (!isLoggedIn.value) return false;
    
    // USER LOGIN:
    // Materi 2 (index 1) selalu terbuka
    if (index == 1) return true;
    
    // Materi 3-10: harus selesaikan materi sebelumnya
    if (!chapters[index - 1]['completed']) return false;
    
    return !chapters[index]['locked'];
  }

  bool canStartQuiz(int chapterIndex) {
    return isChapterAccessible(chapterIndex);
  }

  void startQuiz(String chapterTitle, int chapterIndex) {
    if (!isChapterAccessible(chapterIndex)) {
      if (!isLoggedIn.value && chapterIndex > 0) {
        Get.snackbar(
          'Login Diperlukan',
          'Silakan login untuk mengakses materi ini',
          backgroundColor: const Color(0xFF73090D),
          colorText: Colors.white,
        );
        Get.toNamed('/login');
      } else if (chapterIndex > 0 && !chapters[chapterIndex - 1]['completed']) {
        Get.snackbar(
          'Materi Terkunci',
          'Selesaikan materi sebelumnya terlebih dahulu!',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
      return;
    }
    
    Get.toNamed('/splash-loading', arguments: {
  'era_id': Get.arguments['id'],
  'chapter': chapterTitle,
  'chapter_index': chapterIndex,
  'isGuest': !isLoggedIn.value,
  'materi_id': chapterIndex + 1,  // ✅ Kirim materi_id
});
  }

  Future<void> completeChapter(int chapterIndex, String eraId) async {
    if (chapterIndex < chapters.length) {
      chapters[chapterIndex]['completed'] = true;
      chapters[chapterIndex]['locked'] = false;
      
      // Buka materi berikutnya
      if (chapterIndex + 1 < chapters.length) {
        chapters[chapterIndex + 1]['locked'] = false;
      }
      
      chapters.refresh();
      _updateProgress();
      
      if (userId != null && eraId.isNotEmpty) {
        try {
          await supabase.from('user_progress').upsert({
            'user_id': userId!,
            'era_id': eraId,
            'chapter_index': chapterIndex,
            'completed': true,
          });
          
          await _checkEraCompletion();
        } catch (e) {
          print('Save progress error: $e');
        }
      }
    }
  }

  bool get isAllChaptersCompleted {
    return chapters.every((chapter) => chapter['completed'] == true);
  }

  Future<void> _checkEraCompletion() async {
    if (isAllChaptersCompleted) {
      Get.snackbar(
        'Selamat! 🎉',
        'Kamu telah menyelesaikan semua materi Era 1!\nEra 2 sekarang terbuka.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().fetchQuizzes();
      }
    }
  }

  String getProgressPercent() {
    return '${(progress.value * 100).toInt()}%';
  }
}