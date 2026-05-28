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
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        _buildTopThree(controller),
                        const SizedBox(height: 30),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.otherRanks.length,
                          itemBuilder: (context, index) {
                            final item = controller.otherRanks[index];

                            return _buildRankItem(
                              rank: item['rank'],
                              name: item['name'],
                              score: item['score'],
                            );
                          },
                        ),

                        // ruang agar list tidak tertutup pinned card
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),

                const CustomBottomNavbar(currentIndex: 1),
              ],
            ),

            // PINNED USER CARD
            _buildCurrentUserCard(controller),
          ],
        );
      }),
    );
  }

  Widget _buildTopThree(LeaderboardController controller) {
    final top3 = controller.topThree;

    final rank1Name = top3.isNotEmpty ? top3[0]['name'] : 'Player';
    final rank1Score = top3.isNotEmpty ? top3[0]['score'] : 0;

    final rank2Name = top3.length > 1 ? top3[1]['name'] : 'Player';
    final rank2Score = top3.length > 1 ? top3[1]['score'] : 0;

    final rank3Name = top3.length > 2 ? top3[2]['name'] : 'Player';
    final rank3Score = top3.length > 2 ? top3[2]['score'] : 0;

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
            name: rank2Name,
            score: rank2Score,
            avatarColor: const Color(0xFF9E9E9E),
            podiumColor: const Color(0xFFBDBDBD),
            podiumHeight: 90,
            avatarRadius: 30,
          ),

          const SizedBox(width: 12),

          _buildPodiumItem(
            rank: 1,
            name: rank1Name,
            score: rank1Score,
            avatarColor: const Color(0xFFB8860B),
            podiumColor: const Color(0xFFDAA520),
            podiumHeight: 130,
            avatarRadius: 38,
            isWinner: true,
          ),

          const SizedBox(width: 12),

          _buildPodiumItem(
            rank: 3,
            name: rank3Name,
            score: rank3Score,
            avatarColor: const Color(0xFF795548),
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
    required Color avatarColor,
    required Color podiumColor,
    required double podiumHeight,
    required double avatarRadius,
    bool isWinner = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isWinner ? 3 : 2,
            ),
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
            backgroundColor: avatarColor,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: isWinner ? 26 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: 85,
          child: Text(
            name,
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

  Widget _buildRankItem({
    required int rank,
    required String name,
    required int score,
  }) {
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
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(
                color: Color(0xFF73090D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Row(
            children: [
              const Icon(
                Icons.star,
                size: 18,
                color: Color(0xFFFFD700),
              ),

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
    return Positioned(
      left: 16,
      right: 16,
      bottom: 73,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF73090D),
            width: 1.5,
          ),
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

            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF73090D),
              child: Text(
                'K',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Text(
                'Kamu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF73090D),
                ),
              ),
            ),

            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 18,
                  color: Color(0xFFFFD700),
                ),

                const SizedBox(width: 4),

                Obx(() => Text(
                  _formatScore(controller.currentUserScore.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF73090D),
                  ),
                )),
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