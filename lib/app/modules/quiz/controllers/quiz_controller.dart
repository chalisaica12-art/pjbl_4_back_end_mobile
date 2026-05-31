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

  // Soal-soal (Era Prakasa - Meganthropus Paleojavanicus)
  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Siapakah tokoh yang pertama kali menemukan fosil manusia purba Meganthropus Paleojavanicus?',
      'image': null,
      'options': [
        'Eugene Dubois',
        'G.H.R. von Koenigswald',
        'Ter Haar',
        'Raden Saleh',
      ],
      'answer': 'G.H.R. von Koenigswald',
    },
    {
      'question': 'Di daerah manakah fosil rahang dan gigi Meganthropus Paleojavanicus pertama kali ditemukan?',
      'image': null,
      'options': [
        'Trinil, Ngawi',
        'Wajak, Tulungagung',
        'Sangiran, Sragen',
        'Ngandong, Blora',
      ],
      'answer': 'Sangiran, Sragen',
    },
    {
      'question': 'Secara harfiah atau etimologi, apa arti dari nama "Meganthropus Paleojavanicus"?',
      'image': null,
      'options': [
        'Manusia kera dari Jawa yang berjalan tegak',
        'Manusia raksasa tua dari Jawa',
        'Manusia cerdas yang berasal dari Pulau Jawa',
        'Manusia kera yang memiliki tubuh perkasa',
      ],
      'answer': 'Manusia raksasa tua dari Jawa',
    },
    {
      'question': 'Berdasarkan struktur rahangnya yang sangat besar dan kuat serta tidak memiliki dagu, apa jenis makanan utama dari Meganthropus Paleojavanicus?',
      'image': null,
      'options': [
        'Daging hewan buruan yang dibakar',
        'Tumbuh-tumbuhan dan buah-buahan',
        'Ikan dan kerang-kerangan sungai',
        'Segala jenis makanan yang sudah dimasak',
      ],
      'answer': 'Tumbuh-tumbuhan dan buah-buahan',
    },
    {
      'question': 'Fosil Meganthropus Paleojavanicus ditemukan pada lapisan tanah Jetis. Lapisan ini juga sering disebut sebagai lapisan...',
      'image': null,
      'options': [
        'Pleistosen Atas',
        'Pleistosen Tengah',
        'Pleistosen Bawah',
        'Holosen',
      ],
      'answer': 'Pleistosen Bawah',
    },
  ];

  Map<String, dynamic> get currentQuestionData => questions[currentQuestion.value];
  int get totalQuestions => questions.length;

  String? get currentUserId => supabase.auth.currentUser?.id;
  bool get isGuest => currentUserId == null;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
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

  // ✅ Hitung stars berdasarkan skor
  int _hitungStars(int correct, int total) {
    final persen = (correct / total) * 100;
    if (persen >= 80) return 3;
    if (persen >= 60) return 2;
    if (persen >= 40) return 1;
    return 0;
  }

  // ✅ Simpan score ke Supabase (hanya kalau sudah login)
  Future<void> _simpanScore() async {
    if (isGuest) return; // guest tidak disimpan

    try {
      final score = (correctAnswers.value * 100 ~/ totalQuestions);
      final stars = _hitungStars(correctAnswers.value, totalQuestions);
      final xpDapat = correctAnswers.value * 20; // 20 XP per jawaban benar

      // Simpan ke tabel quiz_scores
      await supabase.from('quiz_scores').insert({
        'user_id': currentUserId,
        'score': score,
        'correct_answers': correctAnswers.value,
        'total_questions': totalQuestions,
        'duration_seconds': (minutes.value * 60) + seconds.value,
        'stars_earned': stars,
        'played_at': DateTime.now().toIso8601String(),
      });

      // Update stars dan XP di tabel profiles
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

      // Hitung level up
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

      print('Score tersimpan: score=$score, stars=$stars, xp=$xpDapat');
    } catch (e) {
      print('Error simpan score: $e');
    }
  }

  void cekJawaban() {
    if (selectedAnswer.value.isEmpty) return;

    sudahKlikNext.value = true;
    isCorrect.value = (selectedAnswer.value == currentQuestionData['answer']);
    if (isCorrect.value) correctAnswers.value++;

    Future.delayed(const Duration(seconds: 2), () async {
      if (currentQuestion.value < totalQuestions - 1) {
        currentQuestion.value++;
        selectedAnswer.value = '';
        sudahKlikNext.value = false;
        isCorrect.value = false;
      } else {
        _timer?.cancel();

        // ✅ Simpan score dulu sebelum navigasi
        await _simpanScore();

        Get.toNamed('/score', arguments: {
          'totalMinutes': minutes.value,
          'totalSeconds': seconds.value,
          'correctAnswers': correctAnswers.value,
          'totalQuestions': totalQuestions,
          'isGuest': isGuest, // ✅ kirim info guest ke score view
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