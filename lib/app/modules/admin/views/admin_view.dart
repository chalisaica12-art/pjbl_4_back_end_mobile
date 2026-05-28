import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import 'manage_users_view.dart';
import 'manage_eras_view.dart';
import 'manage_questions_view.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDE7E4), // Warna background tema
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF73090D), // Warna merah tema
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar dengan warna tema
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSidebarItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                  currentIndex: controller.selectedIndex.value,
                  onTap: () => controller.changeTab(0),
                ),
                _buildSidebarItem(
                  icon: Icons.people,
                  title: 'Kelola User',
                  index: 1,
                  currentIndex: controller.selectedIndex.value,
                  onTap: () => controller.changeTab(1),
                ),
                _buildSidebarItem(
                  icon: Icons.history_edu,
                  title: 'Kelola Era',
                  index: 2,
                  currentIndex: controller.selectedIndex.value,
                  onTap: () => controller.changeTab(2),
                ),
                _buildSidebarItem(
                  icon: Icons.quiz,
                  title: 'Kelola Soal',
                  index: 3,
                  currentIndex: controller.selectedIndex.value,
                  onTap: () => controller.changeTab(3),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Questoria Admin v1.0',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Obx(() {
              switch (controller.selectedIndex.value) {
                case 0:
                  return _buildDashboard(controller);
                case 1:
                  return const ManageUsersView();
                case 2:
                  return const ManageErasView();
                case 3:
                  return const ManageQuestionsView();
                default:
                  return _buildDashboard(controller);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF73090D) : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF73090D) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? const Color(0xFF73090D).withOpacity(0.1) : null,
      onTap: onTap,
    );
  }

  Widget _buildDashboard(AdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF73090D)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                title: 'Total User',
                value: '${controller.users.length}',
                icon: Icons.people,
                color: const Color(0xFF73090D),
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                title: 'Total Era',
                value: '${controller.eras.length}',
                icon: Icons.history_edu,
                color: const Color(0xFF73090D),
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                title: 'Total Soal',
                value: '${controller.questions.length}',
                icon: Icons.quiz,
                color: const Color(0xFF73090D),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...controller.users.take(5).map((user) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF73090D).withOpacity(0.2),
                    child: Text(
                      user['name'][0],
                      style: const TextStyle(color: Color(0xFF73090D)),
                    ),
                  ),
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user['status'] == 'active' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}