import 'package:get/get.dart';

class QuizDetailController extends GetxController {
  var progress = 0.0.obs;
  var currentScore = 0.obs;
  var totalQuestions = 10.obs;
  
  var chapters = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    final quizData = Get.arguments as Map<String, dynamic>;
    loadChapters(quizData);
  }
  
  void loadChapters(Map<String, dynamic> quizData) {
    // Data chapter baru sesuai daftar
    chapters.value = [
      {'title': 'Meganthropus Paleojavanicus', 'completed': false, 'locked': false},
      {'title': 'Pithecanthropus Erectus', 'completed': false, 'locked': true},
      {'title': 'Jenis-Jenis Manusia Cerdas', 'completed': false, 'locked': true},
      {'title': 'Masa Berburu dan Meramu Tingkat Awal', 'completed': false, 'locked': true},
      {'title': 'Masa Berburu Tingkat Lanjut', 'completed': false, 'locked': true},
      {'title': 'Masa Bercocok Tanam ', 'completed': false, 'locked': true},
      {'title': 'Zaman Batu (Paleolitikum & Mesolitikum)', 'completed': false, 'locked': true},
      {'title': 'Zaman Batu Muda (Neolitikum)', 'completed': false, 'locked': true},
      {'title': 'Zaman Megalitikum (Batu Besar)', 'completed': false, 'locked': true},
      {'title': 'Zaman Logam (Perundagian)', 'completed': false, 'locked': true},
    ];
    
    _updateProgress();
  }
  
  void _updateProgress() {
    int completedCount = chapters.where((c) => c['completed'] == true).length;
    progress.value = completedCount / chapters.length;
    currentScore.value = completedCount * 10; // 10 XP per chapter
    totalQuestions.value = chapters.length * 5; // 5 pertanyaan per chapter
  }
  
  void startQuiz(String chapterTitle) {
    // Navigasi ke splash loading dulu
    Get.toNamed('/splash-loading', arguments: {
      'era_id': Get.arguments['id'],
      'chapter': chapterTitle,
    });
  }
  
  void completeChapter(int chapterIndex) {
    if (chapterIndex < chapters.length) {
      chapters[chapterIndex]['completed'] = true;
      
      // Buka bab berikutnya
      if (chapterIndex + 1 < chapters.length) {
        chapters[chapterIndex + 1]['locked'] = false;
      }
      
      chapters.refresh();
      _updateProgress();
    }
  }
  
  String getProgressPercent() {
    return '${(progress.value * 100).toInt()}%';
  }
}