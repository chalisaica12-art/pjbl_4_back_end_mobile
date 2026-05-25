import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeaderboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4),
      appBar: AppBar(
        title: const Text(
          '🏆 Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF73090D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF73090D)),
          );
        }
        return Column(
          children: [
            // Top 3 Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF73090D),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Runner up (rank 2)
                  _buildTop3Card(
                    rank: 2,
                    name: controller.leaderboardList.length > 1 
                        ? controller.leaderboardList[1]['name'] 
                        : 'User',
                    score: controller.leaderboardList.length > 1 
                        ? controller.leaderboardList[1]['score'] 
                        : 0,
                    avatar: controller.leaderboardList.length > 1 
                        ? controller.leaderboardList[1]['avatar'] 
                        : 'assets/gambar/profile.png',
                  ),
                  // Winner (rank 1)
                  _buildTop3Card(
                    rank: 1,
                    name: controller.leaderboardList.isNotEmpty 
                        ? controller.leaderboardList[0]['name'] 
                        : 'User',
                    score: controller.leaderboardList.isNotEmpty 
                        ? controller.leaderboardList[0]['score'] 
                        : 0,
                    avatar: controller.leaderboardList.isNotEmpty 
                        ? controller.leaderboardList[0]['avatar'] 
                        : 'assets/gambar/profile.png',
                    isWinner: true,
                  ),
                  // Third (rank 3)
                  _buildTop3Card(
                    rank: 3,
                    name: controller.leaderboardList.length > 2 
                        ? controller.leaderboardList[2]['name'] 
                        : 'User',
                    score: controller.leaderboardList.length > 2 
                        ? controller.leaderboardList[2]['score'] 
                        : 0,
                    avatar: controller.leaderboardList.length > 2 
                        ? controller.leaderboardList[2]['avatar'] 
                        : 'assets/gambar/profile.png',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Peringkat Lainnya',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF73090D),
                    ),
                  ),
                  Text(
                    'Top 10',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // List peringkat 4 - 10
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.leaderboardList.length > 3 
                    ? controller.leaderboardList.length - 3 
                    : 0,
                itemBuilder: (context, index) {
                  final item = controller.leaderboardList[index + 3];
                  return _buildRankListItem(
                    rank: item['rank'],
                    name: item['name'],
                    score: item['score'],
                    avatar: item['avatar'],
                  );
                },
              ),
            ),
            
            // Current User Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF73090D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF73090D), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    child: Text(
                      '${controller.currentUserRank.value}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF73090D),
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/gambar/profile.png'),
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
                        Icons.stars,
                        size: 16,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 4),
                      Obx(() => Text(
                        '${controller.currentUserScore.value}',
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
          ],
        );
      }),
    );
  }

  // Widget untuk Top 3 Card
  Widget _buildTop3Card({
    required int rank,
    required String name,
    required int score,
    required String avatar,
    bool isWinner = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isWinner ? Colors.amber : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(avatar),
                backgroundColor: Colors.white,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isWinner ? Colors.amber : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isWinner ? Colors.black : const Color(0xFF73090D),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$score XP',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Widget untuk list item (rank 4-10)
  Widget _buildRankListItem({
    required int rank,
    required String name,
    required int score,
    required String avatar,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            width: 35,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(avatar),
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.stars,
                size: 14,
                color: Color(0xFFFFD700),
              ),
              const SizedBox(width: 4),
              Text(
                '$score',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}