import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/controllers/profile_controller.dart';

class ScoreView extends StatelessWidget {
  const ScoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final int totalMinutes = args['totalMinutes'] ?? 0;
    final int totalSeconds = args['totalSeconds'] ?? 0;
    final int correctAnswers = args['correctAnswers'] ?? 0;
    final int totalQuestions = args['totalQuestions'] ?? 5;
    final bool isGuest = args['isGuest'] ?? false;

    // ✅ Ambil data dari ProfileController kalau sudah login
    ProfileController? profileController;
    if (!isGuest && Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    }

    int getScore() =>
        (correctAnswers * 100 ~/ (totalQuestions == 0 ? 1 : totalQuestions));
    int getAccuracy() =>
        totalQuestions == 0 ? 0 : (correctAnswers * 100 ~/ totalQuestions);
    String getDuration() {
      return '${totalMinutes.toString().padLeft(2, '0')}:${totalSeconds.toString().padLeft(2, '0')}';
    }

    int getStars() {
      final persen = getAccuracy();
      if (persen >= 80) return 3;
      if (persen >= 60) return 2;
      if (persen >= 40) return 1;
      return 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Judul
                const Text(
                  "SELAMAT !",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Hasil Kuis Latihan Kamu",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Gambar piala — ukuran lebih besar
                Center(
                  child: Image.asset(
                    'assets/gambar/piala.png',
                    height: 245,
                    width: 245,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.emoji_events,
                      size: 140, // ✅ Icon fallback juga lebih besar
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Card hasil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF73090D),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ✅ Profil baris — nama & foto dari ProfileController
                      Row(
                        children: [
                          // ✅ Avatar dari ProfileController
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(27.5),
                              border: Border.all(
                                  color: Colors.white70, width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(27.5),
                              child: _buildAvatar(profileController, isGuest),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ Nama dari ProfileController
                                Text(
                                  isGuest
                                      ? "Tamu"
                                      : (profileController?.userName.value
                                              .isNotEmpty ==
                                          true
                                          ? profileController!.userName.value
                                          : "Pengguna"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isGuest)
                                  const Text(
                                    "Login untuk simpan skor",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 10),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < getStars()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: const Color(0xFFFFD700),
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Statistik
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _kotakStatistik(getScore().toString(), "Skor"),
                          _kotakStatistik("${getAccuracy()}%", "Akurasi"),
                          _kotakStatistik(getDuration(), "Durasi"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol Coba Lagi & Selesai
                Row(
              children: [
              Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                     // Kembali ke halaman Unit & Materi (QuizDetailView)
          Get.offAllNamed('/quiz-detail', arguments: {
            'id': Get.arguments['era_id'],  // id era 1
            'title': 'Era Prakasa',
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF73090D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 3,
        ),
        child: const Text(
          "Coba Lagi",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ),
    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.offAllNamed('/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF73090D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Selesai",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                // Kalau guest, tombol Login
                if (isGuest) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.offAllNamed('/login'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF73090D), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Login & Simpan Skor",
                        style: TextStyle(
                          color: Color(0xFF73090D),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Build avatar: coba load dari path asset ProfileController
  /// Kalau gagal / guest → tampilkan icon default
  Widget _buildAvatar(ProfileController? profileController, bool isGuest) {
    if (isGuest || profileController == null) {
      return const Icon(Icons.person, size: 35, color: Color(0xFF73090D));
    }

    final avatarPath = profileController.activeAvatarImage;

    // Kalau path kosong atau masih default belum ada avatar
    if (avatarPath.isEmpty) {
      return const Icon(Icons.person, size: 35, color: Color(0xFF73090D));
    }

    return Image.asset(
      avatarPath,
      width: 55,
      height: 55,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person, size: 35, color: Color(0xFF73090D)),
    );
  }

  Widget _kotakStatistik(String nilai, String label) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 65,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            nilai,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}