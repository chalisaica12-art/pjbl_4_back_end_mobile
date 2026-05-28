import 'package:get/get.dart';
import 'dart:async';

class QuizController extends GetxController {
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
      'image': null, // null = tidak ada gambar
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

  void cekJawaban() {
    if (selectedAnswer.value.isEmpty) return;

    sudahKlikNext.value = true;
    isCorrect.value = (selectedAnswer.value == currentQuestionData['answer']);
    if (isCorrect.value) correctAnswers.value++;

    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestion.value < totalQuestions - 1) {
        currentQuestion.value++;
        selectedAnswer.value = '';
        sudahKlikNext.value = false;
        isCorrect.value = false;
      } else {
        _timer?.cancel();
        Get.toNamed('/score', arguments: {
          'totalMinutes': minutes.value,
          'totalSeconds': seconds.value,
          'correctAnswers': correctAnswers.value,
          'totalQuestions': totalQuestions,
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