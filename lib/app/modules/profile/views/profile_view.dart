import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../data/models/avatar_model.dart';
import '../../home/controllers/home_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchProfile();
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final redSectionHeight = (screenHeight / 3) - appBarHeight - statusBarHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => Get.snackbar("Info", "Pengaturan"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: redSectionHeight,
              decoration: const BoxDecoration(
                color: Color(0xFF8B0000),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ============ AVATAR FULL LINGKARAN SEMPURNA ============
                    Obx(() => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: DecorationImage(
                          image: controller.activeAvatarImage.startsWith('http')
                              ? NetworkImage(controller.activeAvatarImage)
                              : AssetImage(controller.activeAvatarImage) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Text(
                            controller.userName.value.isEmpty ? 'Guest' : controller.userName.value,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          )),
                          const SizedBox(height: 8),
                          Obx(() => Container(
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
                                  "${controller.userStars.value} Skor",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          )),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () async {
                              final result = await Get.toNamed('/edit-profile');
                              if (result == true) {
                                await controller.fetchProfile();
                                if (Get.isRegistered<HomeController>()) {
                                  await Get.find<HomeController>().fetchUserProfile();
                                }
                                Get.snackbar("Sukses", "Profil berhasil diperbarui",
                                    backgroundColor: Colors.green, colorText: Colors.white);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B0000), Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Level ${controller.userLevel.value} - ${controller.levelTitle.value}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("XP", style: TextStyle(color: Colors.white70)),
                        Text("${controller.currentXP.value} / ${controller.maxXP.value} XP",
                            style: const TextStyle(color: Colors.white)),
                      ],
                    )),
                    const SizedBox(height: 8),
                    Obx(() => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: controller.xpProgress,
                        backgroundColor: Colors.white30,
                        valueColor: const AlwaysStoppedAnimation(Colors.amber),
                        minHeight: 8,
                      ),
                    )),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                      "${controller.xpPercentage}% to Level ${controller.userLevel.value + 1}",
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(icon: Icons.language, title: "Bahasa", onTap: () => Get.snackbar("Bahasa", "Pilih bahasa")),
                  const Divider(color: Colors.black12, height: 1),
                  _buildMenuItem(icon: Icons.notifications_outlined, title: "Notifikasi", onTap: () => Get.snackbar("Notifikasi", "Pengaturan notifikasi")),
                  const Divider(color: Colors.black12, height: 1),
                  _buildMenuItem(icon: Icons.shopping_bag_outlined, title: "Toko Avatar", onTap: () => _showAvatarShop()),
                  const Divider(color: Colors.black12, height: 1),
                  _buildMenuItem(icon: Icons.logout, title: "Keluar", onTap: () => _showLogoutDialog()),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavbar(currentIndex: 2),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87))),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 24),
          ],
        ),
      ),
    );
  }

  void _showAvatarShop() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Toko Avatar", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "⭐ ${controller.userStars.value} Skor",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: controller.avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = controller.avatars[index];
                    return Obx(() => _buildAvatarCard(
                      avatar,
                      controller.isAvatarUnlocked(avatar.id),
                      controller.isAvatarActive(avatar.id),
                    ));
                  },
                )),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAvatarCard(AvatarModel avatar, bool isUnlocked, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: isActive ? Border.all(color: const Color(0xFF8B0000), width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // AVATAR FULL LINGKARAN
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(avatar.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (!isUnlocked)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 30),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isUnlocked)
            ElevatedButton(
              onPressed: () {
                controller.useAvatar(avatar.id);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? Colors.green : const Color(0xFF8B0000),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                isActive ? "Active" : "Pakai",
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            )
          else
            ElevatedButton(
              onPressed: controller.userStars.value >= avatar.priceStars
                  ? () {
                      controller.buyAvatar(avatar);
                      Get.back();
                      _showAvatarShop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Buka",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}