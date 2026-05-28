import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';

class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizController>();

    return Obx(() {
      final question = controller.currentQuestionData;
      final hasImage = question['image'] != null;
      final options = question['options'] as List<String>;
      final questionNumber = controller.currentQuestion.value + 1;
      final totalQuestions = controller.totalQuestions;
      final progressValue = questionNumber / totalQuestions;

      return Scaffold(
        backgroundColor: const Color(0xffFDE7E4),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      // Judul chapter
                      const Text(
                        "Era Prakasa",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 15),

                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              backgroundColor: const Color(0xFFE0E0E0),
                              color: const Color(0xFF73090D),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$questionNumber/$totalQuestions",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Timer
                      Obx(() => Text(
                        controller.formatTime(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      )),
                      const SizedBox(height: 20),

                      // Kotak merah (soal + jawaban)
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF73090D),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            children: [
                              // Gambar (jika ada)
                              if (hasImage) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    question['image'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      height: 180,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Teks pertanyaan
                              // Kalau ada gambar: teks di bawah gambar
                              // Kalau tidak ada gambar: teks di tengah dengan Spacer
                              if (!hasImage) const Spacer(),
                              Text(
                                question['question'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                              if (!hasImage) const Spacer(),
                              if (hasImage) const Spacer(),

                              // Pilihan jawaban (selalu vertikal, 4 opsi)
                              Column(
                                children: options
                                    .map((option) => _buildOption(controller, option))
                                    .toList(),
                              ),
                              const SizedBox(height: 16),

                              // Tombol NEXT
                              Obx(() => OutlinedButton(
                                onPressed: (controller.selectedAnswer.value.isEmpty ||
                                        controller.sudahKlikNext.value)
                                    ? null
                                    : controller.cekJawaban,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  shape: const StadiumBorder(),
                                  minimumSize: const Size(double.infinity, 50),
                                  disabledForegroundColor: Colors.white38,
                                ),
                                child: const Text(
                                  "NEXT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bar bawah correct/incorrect
        bottomNavigationBar: Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          color: controller.sudahKlikNext.value
              ? (controller.isCorrect.value
                  ? const Color(0xff2CB57E)
                  : const Color(0xffD93D3D))
              : Colors.transparent,
          child: controller.sudahKlikNext.value
              ? Text(
                  controller.isCorrect.value ? " Correct" : " Incorrect",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : const SizedBox.shrink(),
        )),
      );
    });
  }

  Widget _buildOption(QuizController controller, String text) {
    return Obx(() {
      final isSelected = controller.selectedAnswer.value == text;
      final sudahKlik = controller.sudahKlikNext.value;
      final isKunci = text == controller.currentQuestionData['answer'];

      Color bgColor = Colors.white;
      Color borderColor = Colors.transparent;

      if (sudahKlik) {
        if (isKunci) {
          bgColor = const Color(0xff2CB57E); // hijau = jawaban benar
          borderColor = const Color(0xff2CB57E);
        } else if (isSelected && !isKunci) {
          bgColor = const Color(0xffD93D3D); // merah = salah pilih
          borderColor = const Color(0xffD93D3D);
        }
      } else if (isSelected) {
        bgColor = Colors.orange;
        borderColor = Colors.orangeAccent;
      }

      return GestureDetector(
        onTap: () => controller.selectAnswer(text),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: (isSelected || (sudahKlik && isKunci)) ? Colors.white : Colors.black87,
            ),
          ),
        ),
      );
    });
  }
}