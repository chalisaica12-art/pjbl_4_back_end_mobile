import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_detail_controller.dart';

class QuizDetailView extends StatelessWidget {
  const QuizDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuizDetailController>();
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
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Expanded area untuk list Unit & Materi (scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daftar Bab (Unit & Materi)
                  const Text(
                    'Unit & Materi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF73090D),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(() => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = controller.chapters[index];
                      bool canAccess = _isChapterAccessible(controller, index);
                      return _buildChapterCard(
                        title: chapter['title'],
                        isCompleted: chapter['completed'],
                        isLocked: !canAccess,
                        onTap: canAccess ? () {
                          controller.startQuiz(chapter['title']);
                        } : null,
                      );
                    },
                  )),
                ],
              ),
            ),
          ),
          
          // Tombol Lanjutkan (tetap di bawah, naik sedikit)
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

  // Fungsi untuk mengecek apakah bab bisa diakses
  bool _isChapterAccessible(QuizDetailController controller, int index) {
    final chapters = controller.chapters;
    
    if (index == 0) return true;
    
    final previousChapter = chapters[index - 1];
    return previousChapter['completed'] == true;
  }

  Widget _buildChapterCard({
    required String title,
    required bool isCompleted,
    required bool isLocked,
    VoidCallback? onTap,
  }) {
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
            color: isCompleted
                ? const Color(0xFF73090D).withOpacity(0.1)
                : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLocked == true
                ? Icons.lock_outline
                : (isCompleted == true 
                    ? Icons.check_circle 
                    : Icons.lock_open_outlined), // Gembok terbuka, bukan play video
            color: isLocked == true
                ? Colors.grey
                : (isCompleted == true ? Colors.green : const Color(0xFF73090D)),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isCompleted == true ? FontWeight.w600 : FontWeight.normal,
            color: isLocked == true ? Colors.grey : Colors.black87,
          ),
        ),
        trailing: isCompleted == true
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : (isLocked == true 
                ? const Icon(Icons.lock, color: Colors.grey, size: 18)
                : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
      ),
    );
  }

  Widget _buildContinueButton(QuizDetailController controller) {
    // Cari bab pertama yang belum selesai dan bisa diakses
    dynamic nextChapter;
    for (int i = 0; i < controller.chapters.length; i++) {
      final chapter = controller.chapters[i];
      final canAccess = _isChapterAccessible(controller, i);
      if (chapter['completed'] == false && canAccess) {
        nextChapter = chapter;
        break;
      }
    }
    
    if (nextChapter == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Get.snackbar('Selamat!', 'Kamu sudah menyelesaikan semua materi!');
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.startQuiz(nextChapter['title']);
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}