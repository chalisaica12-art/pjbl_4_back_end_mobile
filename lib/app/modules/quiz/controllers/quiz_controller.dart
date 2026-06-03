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
  var isLoading = true.obs;

  // Soal dari database
  var questions = <Map<String, dynamic>>[].obs;

  // Hardcode fallback soal materi 1 (kalau database belum ada)
  final List<Map<String, dynamic>> _fallbackQuestions = [
    {
      'question_text': 'Siapakah tokoh yang pertama kali menemukan fosil manusia purba Meganthropus Paleojavanicus?',
      'option_a': 'Eugene Dubois',
      'option_b': 'G.H.R. von Koenigswald',
      'option_c': 'Ter Haar',
      'option_d': 'Raden Saleh',
      'correct_answer': 'B',
    },
    {
      'question_text': 'Di daerah manakah fosil rahang dan gigi Meganthropus Paleojavanicus pertama kali ditemukan?',
      'option_a': 'Trinil, Ngawi',
      'option_b': 'Wajak, Tulungagung',
      'option_c': 'Sangiran, Sragen',
      'option_d': 'Ngandong, Blora',
      'correct_answer': 'C',
    },
    {
      'question_text': 'Secara harfiah, apa arti dari nama "Meganthropus Paleojavanicus"?',
      'option_a': 'Manusia kera dari Jawa yang berjalan tegak',
      'option_b': 'Manusia raksasa tua dari Jawa',
      'option_c': 'Manusia cerdas yang berasal dari Pulau Jawa',
      'option_d': 'Manusia kera yang memiliki tubuh perkasa',
      'correct_answer': 'B',
    },
    {
      'question_text': 'Berdasarkan struktur rahangnya, apa jenis makanan utama dari Meganthropus Paleojavanicus?',
      'option_a': 'Daging hewan buruan',
      'option_b': 'Ikan dan kerang-kerangan',
      'option_c': 'Tumbuh-tumbuhan dan buah-buahan',
      'option_d': 'Makanan yang sudah dimasak',
      'correct_answer': 'C',
    },
    {
      'question_text': 'Fosil Meganthropus Paleojavanicus ditemukan pada lapisan tanah Jetis, yang disebut sebagai lapisan...',
      'option_a': 'Pleistosen Atas',
      'option_b': 'Pleistosen Tengah',
      'option_c': 'Holosen',
      'option_d': 'Pleistosen Bawah',
      'correct_answer': 'D',
    },
  ];

  Map<String, dynamic> get currentQuestionData => questions[currentQuestion.value];
  int get totalQuestions => questions.length;

  String? get currentUserId => supabase.auth.currentUser?.id;
  bool get isGuest => currentUserId == null;

  // Argument dari splash loading
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

    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      isLoading.value = true;

      if (materialId != null && materialId!.isNotEmpty) {
        // Fetch dari database berdasarkan material_id
        final response = await supabase
            .from('questions')
            .select()
            .eq('material_id', materialId!)
            .order('order_number', ascending: true);

        final List<dynamic> data = response as List<dynamic>;
        if (data.isNotEmpty) {
          questions.value = List<Map<String, dynamic>>.from(data);
        } else {
          // Database kosong, pakai fallback
          questions.value = _fallbackQuestions;
        }
      } else {
        // Tidak ada material_id, pakai fallback
        questions.value = _fallbackQuestions;
      }
    } catch (e) {
      print('Fetch questions error: $e');
      questions.value = _fallbackQuestions;
    } finally {
      isLoading.value = false;
      _startTimer();
    }
  }

  // Helper ambil jawaban dari format database (A/B/C/D)
  String getCorrectAnswerText(Map<String, dynamic> q) {
    final answer = q['correct_answer']?.toString().toUpperCase() ?? '';
    switch (answer) {
      case 'A': return q['option_a'] ?? '';
      case 'B': return q['option_b'] ?? '';
      case 'C': return q['option_c'] ?? '';
      case 'D': return q['option_d'] ?? '';
      default: return answer;
    }
  }

  List<String> getOptions(Map<String, dynamic> q) {
    return [
      q['option_a'] ?? '',
      q['option_b'] ?? '',
      q['option_c'] ?? '',
      q['option_d'] ?? '',
    ];
  }

  void _startTimer() {
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
    final persen = (correct / total) * 100;
    if (persen >= 80) return 3;
    if (persen >= 60) return 2;
    if (persen >= 40) return 1;
    return 0;
  }

  Future<void> _simpanScore() async {
    if (isGuest) return;

    try {
      final score = (correctAnswers.value * 100 ~/ totalQuestions);
      final stars = _hitungStars(correctAnswers.value, totalQuestions);
      final xpDapat = correctAnswers.value * 20;

      await supabase.from('quiz_scores').insert({
        'user_id': currentUserId,
        'score': score,
        'correct_answers': correctAnswers.value,
        'total_questions': totalQuestions,
        'duration_seconds': (minutes.value * 60) + seconds.value,
        'stars_earned': stars,
        'played_at': DateTime.now().toIso8601String(),
      });

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