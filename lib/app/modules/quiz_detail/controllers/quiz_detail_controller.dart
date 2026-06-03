import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../home/controllers/home_controller.dart';

class QuizDetailController extends GetxController {
  final supabase = Supabase.instance.client;

  var progress = 0.0.obs;
  var currentScore = 0.obs;
  var totalQuestions = 0.obs;
  var isLoading = true.obs;
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

  Future<void> loadChapters(Map<String, dynamic> quizData) async {
    try {
      isLoading.value = true;
      final eraId = quizData['id']?.toString() ?? '';

      // Fetch materi dari database
      final response = await supabase
          .from('materials')
          .select('id, title, order_number')
          .eq('era_id', eraId)
          .order('order_number', ascending: true);

      final List<dynamic> materiList = response as List<dynamic>;

      chapters.value = materiList.map((m) => {
        'id': m['id'],
        'title': m['title'],
        'order_number': m['order_number'],
        'completed': false,
        'locked': (m['order_number'] as int) > 1,
      }).toList();

      // Kalau belum ada data di database, fallback ke hardcode sementara
      if (chapters.isEmpty) {
        chapters.value = [
          {'id': null, 'title': 'Meganthropus Paleojavanicus', 'order_number': 1, 'completed': false, 'locked': false},
          {'id': null, 'title': 'Pithecanthropus Erectus', 'order_number': 2, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Jenis-Jenis Manusia Cerdas', 'order_number': 3, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Masa Berburu dan Meramu Tingkat Awal', 'order_number': 4, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Masa Berburu Tingkat Lanjut', 'order_number': 5, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Masa Bercocok Tanam', 'order_number': 6, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Zaman Batu (Paleolitikum & Mesolitikum)', 'order_number': 7, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Zaman Batu Muda (Neolitikum)', 'order_number': 8, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Zaman Megalitikum (Batu Besar)', 'order_number': 9, 'completed': false, 'locked': true},
          {'id': null, 'title': 'Zaman Logam (Perundagian)', 'order_number': 10, 'completed': false, 'locked': true},
        ];
      }

      if (userLoggedIn) {
        await _loadProgressFromDB(eraId);
      }
      _updateProgress();
    } catch (e) {
      print('Load chapters error: $e');
    } finally {
      isLoading.value = false;
    }
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
      print('Load progress error: $e');
    }
  }

  void _updateProgress() {
    int completedCount = chapters.where((c) => c['completed'] == true).length;
    progress.value = chapters.isEmpty ? 0 : completedCount / chapters.length;
    currentScore.value = completedCount * 10;
    totalQuestions.value = chapters.length * 5;
  }

  bool isChapterAccessible(int index) {
    if (index == 0) return true;
    if (!isLoggedIn.value) return false;
    if (index == 1) return true;
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

    final eraArgs = Get.arguments as Map<String, dynamic>;
    Get.toNamed('/splash-loading', arguments: {
      'era_id': eraArgs['id'],
      'era_title': eraArgs['title'],
      'chapter': chapterTitle,
      'chapter_index': chapterIndex,
      'material_id': chapters[chapterIndex]['id'],
      'isGuest': !isLoggedIn.value,
    });
  }

  Future<void> completeChapter(int chapterIndex, String eraId) async {
    if (chapterIndex < chapters.length) {
      chapters[chapterIndex]['completed'] = true;
      chapters[chapterIndex]['locked'] = false;

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
        'Kamu telah menyelesaikan semua materi!\nEra berikutnya sekarang terbuka.',
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