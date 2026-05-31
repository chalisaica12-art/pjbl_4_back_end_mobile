import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/leaderboard_controller.dart';
import '../../../widgets/custom_bottom_navbar.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeaderboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4),
      appBar: AppBar(
        title: const Text(
          'Peringkat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color(0xFF73090D),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchLeaderboard(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF73090D)),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        _buildTopThree(controller),
                        const SizedBox(height: 30),
                        _buildOtherRanks(controller),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
                const CustomBottomNavbar(currentIndex: 1),
              ],
            ),
            Obx(() => _buildCurrentUserCard(controller)),
          ],
        );
      }),
    );
  }

  Widget _buildTopThree(LeaderboardController controller) {
    final top3 = controller.topThree;

    final rank1 = top3.isNotEmpty ? top3[0] : null;
    final rank2 = top3.length > 1 ? top3[1] : null;
    final rank3 = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF73090D), Color(0xFFFDE7E4)],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(
            rank: 2,
            name: rank2?['name'] ?? '-',
            score: rank2?['score'] ?? 0,
            avatarPath: rank2?['avatar_path'] ?? '',
            podiumColor: const Color(0xFFBDBDBD),
            podiumHeight: 90,
            avatarRadius: 30,
          ),
          const SizedBox(width: 12),
          _buildPodiumItem(
            rank: 1,
            name: rank1?['name'] ?? '-',
            score: rank1?['score'] ?? 0,
            avatarPath: rank1?['avatar_path'] ?? '',
            podiumColor: const Color(0xFFDAA520),
            podiumHeight: 130,
            avatarRadius: 38,
            isWinner: true,
          ),
          const SizedBox(width: 12),
          _buildPodiumItem(
            rank: 3,
            name: rank3?['name'] ?? '-',
            score: rank3?['score'] ?? 0,
            avatarPath: rank3?['avatar_path'] ?? '',
            podiumColor: const Color(0xFFA1887F),
            podiumHeight: 70,
            avatarRadius: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required int score,
    required String avatarPath,
    required Color podiumColor,
    required double podiumHeight,
    required double avatarRadius,
    bool isWinner = false,
  }) {
    final initial = (name.isNotEmpty && name != '-') ? name[0].toUpperCase() : '?';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: isWinner ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: avatarPath.isNotEmpty
                ? AssetImage(avatarPath) as ImageProvider
                : null,
            child: avatarPath.isEmpty
                ? Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWinner ? 26 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 85,
          child: Text(
            name == '-' ? 'Kosong' : name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isWinner ? 13 : 11,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _formatScore(score),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isWinner ? 12 : 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: isWinner ? 90 : 80,
          height: podiumHeight,
          decoration: BoxDecoration(
            color: podiumColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherRanks(LeaderboardController controller) {
    if (controller.otherRanks.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.otherRanks.length,
      itemBuilder: (context, index) {
        final item = controller.otherRanks[index];
        return _buildRankItem(
          rank: item['rank'],
          name: item['name'],
          score: item['score'],
          avatarPath: item['avatar_path'] ?? '',
        );
      },
    );
  }

  Widget _buildRankItem({
    required int rank,
    required String name,
    required int score,
    required String avatarPath,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF73090D).withOpacity(0.2),
            backgroundImage: avatarPath.isNotEmpty
                ? AssetImage(avatarPath) as ImageProvider
                : null,
            child: avatarPath.isEmpty
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFF73090D),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: Color(0xFFFFD700)),
              const SizedBox(width: 4),
              Text(
                _formatScore(score),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF73090D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserCard(LeaderboardController controller) {
    if (controller.currentUserRank.value == 0) {
      return Positioned(
        left: 16,
        right: 16,
        bottom: 73,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF73090D), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: Color(0xFF73090D)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Login untuk melihat peringkat kamu!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF73090D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed('/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF73090D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final userName = controller.currentUserName.value;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final avatarPath = controller.currentUserAvatar.value;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 73,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF73090D), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '#${controller.currentUserRank.value}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF73090D),
                ),
              ),
            ),
            avatarPath.isNotEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF73090D),
                    child: ClipOval(
                      child: Image.asset(
                        avatarPath,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF73090D),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userName.isNotEmpty ? userName : 'Kamu',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF73090D),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 18, color: Color(0xFFFFD700)),
                const SizedBox(width: 4),
                Text(
                  _formatScore(controller.currentUserScore.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF73090D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );
  }
}