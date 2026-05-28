import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNavbar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: const BoxDecoration(
        color: Color(0xFF73090D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            index: 0,
            currentIndex: currentIndex,
            route: '/home',
          ),
          _buildNavItem(
            icon: Icons.leaderboard,
            index: 1,
            currentIndex: currentIndex,
            route: '/leaderboard',
          ),
          _buildNavItem(
            icon: Icons.person,
            index: 2,
            currentIndex: currentIndex,
            route: '/profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required int currentIndex,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (currentIndex != index) {
          Get.offAllNamed(route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white70 : Colors.white,
            size: 35,
          ),
          // HAPUS Text label di sini
        ],
      ),
    );
  }
}