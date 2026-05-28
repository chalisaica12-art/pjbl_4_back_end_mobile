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
        leading: Padding(
          padding: const EdgeInsets.only(left: 19),
          child: Obx(() => CircleAvatar(
            backgroundImage: controller.userAvatar.value.isNotEmpty
                ? NetworkImage(controller.userAvatar.value)
                : const AssetImage("assets/gambar/profile.png") as ImageProvider,
            radius: 40,
          )),
        ),
        title: Obx(() => RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "Selamat Datang\n",
                style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: "Halo, ${controller.userName.value}!",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Notifikasi"),
                  content: const Text("Apakah Anda ingin mengaktifkan notifikasi?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tidak", style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Ya", style: TextStyle(color: Color(0xff73090D))),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
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
            child: CustomBottomNavbar(currentIndex: 0), // 0 = Home
          ),
        ],
      ),
    );
  }

  Widget _homeContent(HomeController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Carousel
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
                onPageChanged: (index) => controller.currentBannerPage.value = index,
                itemCount: controller.bannerImages.length,
                itemBuilder: (context, index) => Image.asset(
                  controller.bannerImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Banner Indicators
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.bannerImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: controller.currentBannerPage.value == index ? 24 : 8,
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

          // Header Section
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

          // Journey List
          Obx(() => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.quizList.length,
            itemBuilder: (context, index) {
              final item = controller.quizList[index];
              final quizId = item['id'].toString();
              final isLocked = item['is_locked'] ?? true;
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

  // Card dengan tulisan "5 Pertanyaan"
  Widget _journeyCard({
    required HomeController controller,
    required Map<String, dynamic> item,
    required String quizId,
    required bool isLocked,
    required int index,
  }) {
    // Fungsi untuk mendapatkan judul era berdasarkan order_number
    String getEraTitle(int orderNumber) {
      switch (orderNumber) {
        case 1: return 'Era Prakasa';
        case 2: return 'Era Kerajaan Hindu Budha';
        case 3: return 'Era Kerajaan Islam';
        case 4: return 'Era Kolonialisme/Penjajahan';
        case 5: return 'Era Kemerdekaan';
        case 6: return 'Era Orde Lama';
        case 7: return 'Era Orde Baru';
        case 8: return 'Reformasi';
        default: return item['title'] ?? 'Quiz Title';
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
            // Bagian Gambar dengan overlay lock
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
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: Image.asset(
                      item['image'] ?? 'assets/gambar/default.jpg',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Overlay lock icon jika terkunci
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
                      child: Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                // Badge Era di pojok kiri atas
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            // Bagian konten bawah (title + 5 pertanyaan)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getEraTitle(item['order_number']), // <-- JUDUL SUDAH DIGANTI
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isLocked ? Colors.grey.shade600 : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Tulisan "5 Pertanyaan" (tanpa icon)
                  Text(
                    '5 Pertanyaan',
                    style: TextStyle(
                      fontSize: 11,
                      color: isLocked ? Colors.grey.shade400 : Colors.grey.shade600,
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