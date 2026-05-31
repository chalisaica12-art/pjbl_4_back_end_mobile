import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_detail_controller.dart';

class QuizDetailView extends StatelessWidget {
  const QuizDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuizDetailController());
    final quizData = Get.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4),
      appBar: AppBar(
        title: Text(
          quizData['title'] ?? 'Detail Era',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF73090D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // ✅ LANGSUNG KE HOME (TIDAK PAKAI Get.back)
            Get.offAllNamed('/home');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info login banner (kalau belum login)
                  Obx(() {
                    if (!controller.isLoggedIn.value) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF73090D).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF73090D).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Color(0xFF73090D), size: 20),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Login untuk membuka semua materi & simpan progres',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF73090D)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed('/login'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF73090D),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Login',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const Text(
                    'Unit & Materi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF73090D),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // List chapter dengan pengecekan login dari controller
                  Obx(() => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = controller.chapters[index];
                          final bool canAccess =
                              controller.isChapterAccessible(index);
                          final bool isCompleted =
                              chapter['completed'] == true;

                          return _buildChapterCard(
                            index: index,
                            title: chapter['title'],
                            isCompleted: isCompleted,
                            isLocked: !canAccess,
                            needsLogin: index > 0 &&
                                !controller.isLoggedIn.value,
                            onTap: () {
                              controller.startQuiz(chapter['title'], index);
                            },
                          );
                        },
                      )),
                ],
              ),
            ),
          ),

          // Tombol Lanjutkan di bawah
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE7E4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Obx(() => _buildContinueButton(controller)),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard({
    required int index,
    required String title,
    required bool isCompleted,
    required bool isLocked,
    required bool needsLogin,
    required VoidCallback onTap,
  }) {
    IconData leadingIcon;
    Color leadingColor;
    Color bgColor;

    if (isCompleted) {
      leadingIcon = Icons.check_circle;
      leadingColor = Colors.green;
      bgColor = const Color(0xFF73090D).withOpacity(0.1);
    } else if (needsLogin) {
      leadingIcon = Icons.lock_outline;
      leadingColor = const Color(0xFF73090D);
      bgColor = Colors.grey.shade100;
    } else if (isLocked) {
      leadingIcon = Icons.lock_outline;
      leadingColor = Colors.grey;
      bgColor = Colors.grey.shade100;
    } else {
      leadingIcon = Icons.lock_open_outlined;
      leadingColor = const Color(0xFF73090D);
      bgColor = Colors.grey.shade100;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(leadingIcon, color: leadingColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            color: isLocked && !needsLogin ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: needsLogin && !isCompleted
            ? const Text(
                'Login untuk membuka',
                style: TextStyle(fontSize: 11, color: Color(0xFF73090D)),
              )
            : null,
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : (isLocked && !needsLogin
                ? const Icon(Icons.lock, color: Colors.grey, size: 18)
                : const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey)),
      ),
    );
  }

  Widget _buildContinueButton(QuizDetailController controller) {
    int? nextIndex;
    for (int i = 0; i < controller.chapters.length; i++) {
      final chapter = controller.chapters[i];
      final canAccess = controller.isChapterAccessible(i);
      if (chapter['completed'] == false && canAccess) {
        nextIndex = i;
        break;
      }
    }

    if (nextIndex == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Get.snackbar('Selamat!', 'Kamu sudah menyelesaikan semua materi!',
                backgroundColor: Colors.green,
                colorText: Colors.white);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            '🎉 SELESAI SEMUA 🎉',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      );
    }

    final nextChapter = controller.chapters[nextIndex];

    if (nextIndex > 0 && !controller.isLoggedIn.value) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.toNamed('/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF73090D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            '🔒 LOGIN UNTUK LANJUTKAN',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.startQuiz(nextChapter['title'], nextIndex!);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF73090D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'LANJUTKAN BELAJAR',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}