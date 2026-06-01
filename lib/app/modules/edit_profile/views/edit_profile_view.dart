import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../data/models/avatar_model.dart';
import '../../profile/controllers/profile_controller.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditProfileController>();
    final profileController = Get.find<ProfileController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final redSectionHeight = (screenHeight / 3) - appBarHeight - statusBarHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() => IconButton(
            icon: controller.isLoading.value
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, color: Colors.green),
            onPressed: controller.isLoading.value ? null : controller.saveProfile,
          )),
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
              child: Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Avatar
                    Obx(() {
                      final avatarImage = controller.activeAvatarImage.value;
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: ClipOval(
                          child: avatarImage.isEmpty
                              ? Image.asset(
                                  "assets/gambar/gam1.png",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                )
                              : avatarImage.startsWith('http')
                                  ? Image.network(
                                      avatarImage,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      avatarImage,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                        ),
                      );
                    }),
                    // ✅ ICON PENSIL DI POJOK KANAN BAWAH AVATAR (untuk inventaris)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => _showAvatarInventory(profileController, controller),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFF8B0000),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama"),
                  const SizedBox(height: 8),
                  _buildTextField(controller: controller.nameController, hintText: "Masukkan nama"),
                  const SizedBox(height: 20),
                  _buildLabel("Alamat Email"),
                  const SizedBox(height: 8),
                  _buildTextField(controller: controller.emailController, hintText: "email@gmail.com", enabled: false),
                  const SizedBox(height: 20),
                  _buildLabel("Nomor Telepon"),
                  const SizedBox(height: 8),
                  _buildTextField(controller: controller.phoneController, hintText: "Masukkan nomor telepon", keyboardType: TextInputType.phone),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFE8E8E8) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  // ✅ INVENTARIS AVATAR
  void _showAvatarInventory(ProfileController profileController, EditProfileController editController) {
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
            const Text(
              "Inventaris Avatar",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                    "${profileController.userStars.value} Bintang",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final ownedAvatars = profileController.avatars
                    .where((a) => profileController.unlockedAvatarIds.contains(a.id))
                    .toList();

                if (ownedAvatars.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Belum punya avatar', style: TextStyle(color: Colors.grey)),
                        Text('Buka Toko Avatar untuk membeli', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: ownedAvatars.length,
                  itemBuilder: (context, index) {
                    final avatar = ownedAvatars[index];
                    final isActive = profileController.activeAvatarId.value == avatar.id;

                    return GestureDetector(
                      onTap: () async {
                        await profileController.useAvatar(avatar.id);
                        await editController.loadProfile();
                        Get.back();
                        Get.snackbar(
                          'Sukses',
                          'Avatar ${avatar.name} aktif!',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: isActive
                              ? Border.all(color: Colors.green, width: 3)
                              : Border.all(color: Colors.grey.shade200, width: 1),
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
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  child: ClipOval(
                                    child: Image.asset(
                                      avatar.imagePath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isActive)
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check_circle, color: Colors.white, size: 30),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              avatar.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? Colors.green : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}