import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/custom_bottom_navbar.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDE7E4),
        elevation: 0,
        leading: controller.isGuest
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 19),
                child: Obx(() {
                  final avatar = controller.userAvatar.value;
                  final userName = controller.userName.value;
                  
                  if (avatar.isEmpty) {
                    final initial = userName.isNotEmpty
                        ? userName[0].toUpperCase()
                        : '?';
                    return CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF73090D),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  
                  return CircleAvatar(
                    radius: 40,
                    backgroundImage: avatar.startsWith('http')
                        ? NetworkImage(avatar) as ImageProvider
                        : AssetImage(avatar) as ImageProvider,
                    backgroundColor: Colors.grey.shade200,
                  );
                }),
              ),
        title: controller.isGuest
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.toNamed('/login'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF73090D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                          color: Color(0xFF73090D),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF73090D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
              )
            : Obx(() => RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Selamat Datang\n",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: "Halo, ${controller.userName.value}!",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                )),
        // ✅ BINTANG HANYA TAMPIL KALAU SUDAH LOGIN
        actions: [
          if (!controller.isGuest)
            Obx(() => Container(
              margin: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.userStars.value} Bintang',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchQuizzes(),
        child: Stack(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF73090D)),
                );
              }
              return _homeContent(controller);
            }),
            const Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavbar(currentIndex: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeContent(HomeController controller) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) =>
                    controller.currentBannerPage.value = index,
                itemCount: controller.bannerImages.length,
                itemBuilder: (context, index) => Image.asset(
                  controller.bannerImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.bannerImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: controller.currentBannerPage.value == index
                        ? 24
                        : 8,
                    decoration: BoxDecoration(
                      color: controller.currentBannerPage.value == index
                          ? const Color(0xFF73090D)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 24),
          const Text(
            "Perjalanan Sejarah Indonesia",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF73090D),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Selesaikan setiap era untuk membuka era berikutnya!",
            style: TextStyle(
              fontSize: 13,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.quizList.length,
                itemBuilder: (context, index) {
                  final item = controller.quizList[index];
                  final quizId = item['id'].toString();
                  final isLocked =
                      !controller.isUnlocked(item['order_number'] ?? 1);
                  return _journeyCard(
                    controller: controller,
                    item: item,
                    quizId: quizId,
                    isLocked: isLocked,
                    index: index,
                  );
                },
              )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _journeyCard({
    required HomeController controller,
    required Map<String, dynamic> item,
    required String quizId,
    required bool isLocked,
    required int index,
  }) {
    String getEraTitle(int orderNumber) {
      switch (orderNumber) {
        case 1:
          return 'Era Prakasa';
        case 2:
          return 'Era Kerajaan Hindu Budha';
        case 3:
          return 'Era Kerajaan Islam';
        default:
          return item['title'] ?? 'Quiz Title';
      }
    }

    return GestureDetector(
      onTap: () => controller.onQuizTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: ColorFiltered(
                    colorFilter: isLocked
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ])
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply),
                    child: Image.asset(
                      item['image'] ?? 'assets/gambar/default.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (isLocked)
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_outline,
                          color: Colors.white, size: 48),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF73090D), Color(0xFFA0151A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Era ${item['order_number']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getEraTitle(item['order_number']),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          isLocked ? Colors.grey.shade600 : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '5 Pertanyaan',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLocked
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}