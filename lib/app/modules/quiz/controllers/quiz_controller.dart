import 'package:get/get.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizController extends GetxController {
  final supabase = Supabase.instance.client;

  // Timer
  var seconds = 0.obs;
  var minutes = 0.obs;
  Timer? _timer;

  // State
  var currentQuestion = 0.obs;
  var selectedAnswer = ''.obs;
  var sudahKlikNext = false.obs;
  var isCorrect = false.obs;
  var correctAnswers = 0.obs;
  var isLoading = true.obs;  // ✅ PENTING: buat loading state

  // Soal dari database
  var questions = <Map<String, dynamic>>[].obs;

  // ✅ GETTER AMAN
  Map<String, dynamic> get currentQuestionData {
    if (questions.isEmpty || currentQuestion.value >= questions.length) {
      return {};  // return empty map, bukan null
    }
    return questions[currentQuestion.value];
  }
  
  int get totalQuestions => questions.length;

  String? get currentUserId => supabase.auth.currentUser?.id;
  bool get isGuest => currentUserId == null;

  // Argument
  late String eraId;
  late String eraTitle;
  late String chapterTitle;
  late int chapterIndex;
  String? materialId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    eraId = args['era_id']?.toString() ?? '';
    eraTitle = args['era_title']?.toString() ?? '';
    chapterTitle = args['chapter']?.toString() ?? '';
    chapterIndex = args['chapter_index'] ?? 0;
    materialId = args['material_id']?.toString();

    fetchQuestions();  // ambil data dari database
  }

  Future<void> fetchQuestions() async {
    try {
      isLoading.value = true;  // ✅ mulai loading
      
      // Ambil dari DATABASE, BUKAN HARDCODE
      final response = await supabase
          .from('questions')
          .select()
          .eq('material_id', materialId ?? '')
          .order('order_number', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      
      if (data.isNotEmpty) {
        questions.value = List<Map<String, dynamic>>.from(data);
      } else {
        // Optional: pakai fallback kalau database kosong
        questions.value = [];
        // Tampilkan pesan error
        Get.snackbar('Error', 'Tidak ada soal untuk materi ini');
      }
      
    } catch (e) {
      print('Fetch questions error: $e');
      questions.value = [];
      Get.snackbar('Error', 'Gagal mengambil data soal: $e');
    } finally {
      isLoading.value = false;  // ✅ selesai loading
      if (questions.isNotEmpty) {
        _startTimer();
      }
    }
  }

  // ✅ METHOD GET OPTIONS YANG AMAN
  // METHOD GET OPTIONS YANG AMAN - VERSION SIMPLE
List<String> getOptions(Map<String, dynamic> q) {
  if (q.isEmpty) return [];
  
  final List<String> result = [];
  result.add(q['option_a'] ?? '');
  result.add(q['option_b'] ?? '');
  result.add(q['option_c'] ?? '');
  result.add(q['option_d'] ?? '');
  
  return result;
}

  // ✅ METHOD GET CORRECT ANSWER
  String getCorrectAnswerText(Map<String, dynamic> q) {
    if (q.isEmpty) return '';
    
    final answer = q['correct_answer']?.toString().toUpperCase() ?? '';
    switch (answer) {
      case 'A': return q['option_a'] ?? '';
      case 'B': return q['option_b'] ?? '';
      case 'C': return q['option_c'] ?? '';
      case 'D': return q['option_d'] ?? '';
      default: return answer;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds.value++;
      if (seconds.value >= 60) {
        minutes.value++;
        seconds.value = 0;
      }
    });
  }

  String formatTime() {
    return '${minutes.value.toString().padLeft(2, '0')}:${seconds.value.toString().padLeft(2, '0')}';
  }

  void selectAnswer(String answer) {
    if (!sudahKlikNext.value) {
      selectedAnswer.value = answer;
    }
  }

  int _hitungStars(int correct, int total) {
    if (total == 0) return 0;
    final persen = (correct / total) * 100;
    if (persen >= 80) return 3;
    if (persen >= 60) return 2;
    if (persen >= 40) return 1;
    return 0;
  }

  Future<void> _simpanScore() async {
    if (isGuest) return;
    if (totalQuestions == 0) return;

    try {
      final score = (correctAnswers.value * 100 ~/ totalQuestions);
      final stars = _hitungStars(correctAnswers.value, totalQuestions);
      final xpDapat = correctAnswers.value * 20;

      await supabase.from('quiz_scores').insert({
        'user_id': currentUserId,
        'material_id': materialId,  // ✅ simpan juga material_id
        'score': score,
        'correct_answers': correctAnswers.value,
        'total_questions': totalQuestions,
        'duration_seconds': (minutes.value * 60) + seconds.value,
        'stars_earned': stars,
        'played_at': DateTime.now().toIso8601String(),
      });

      // Update profil user
      final profileResponse = await supabase
          .from('profiles')
          .select('stars, xp, level')
          .eq('id', currentUserId!)
          .single();

      final currentStars = profileResponse['stars'] ?? 0;
      final currentXP = profileResponse['xp'] ?? 0;
      final currentLevel = profileResponse['level'] ?? 1;

      final newStars = currentStars + stars;
      final newXP = currentXP + xpDapat;

      int maxXP = 1000 + ((currentLevel as int) - 1) * 500;
      int finalXP = newXP;
      int finalLevel = currentLevel;

      if (finalXP >= maxXP) {
        finalLevel++;
        finalXP = finalXP - maxXP;
      }

      await supabase.from('profiles').update({
        'stars': newStars,
        'xp': finalXP,
        'level': finalLevel,
      }).eq('id', currentUserId!);
      
    } catch (e) {
      print('Error simpan score: $e');
    }
  }

  void cekJawaban() {
    if (selectedAnswer.value.isEmpty) return;
    if (totalQuestions == 0) return;

    sudahKlikNext.value = true;
    final correctText = getCorrectAnswerText(currentQuestionData);
    isCorrect.value = (selectedAnswer.value == correctText);
    if (isCorrect.value) correctAnswers.value++;

    Future.delayed(const Duration(seconds: 2), () async {
      if (currentQuestion.value < totalQuestions - 1) {
        currentQuestion.value++;
        selectedAnswer.value = '';
        sudahKlikNext.value = false;
        isCorrect.value = false;
      } else {
        _timer?.cancel();
        await _simpanScore();

        Get.toNamed('/score', arguments: {
          'era_id': eraId,
          'era_title': eraTitle,
          'chapter': chapterTitle,
          'chapter_index': chapterIndex,
          'material_id': materialId,
          'totalMinutes': minutes.value,
          'totalSeconds': seconds.value,
          'correctAnswers': correctAnswers.value,
          'totalQuestions': totalQuestions,
          'isGuest': isGuest,
        });
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}