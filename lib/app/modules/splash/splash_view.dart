import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          return Stack(
            children: [
              Container(color: Colors.white),

              // Lingkaran merah membesar
              Center(
                child: Transform.scale(
                  scale: controller.scaleAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF73090D),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // Logo muncul di akhir
              Center(
                child: Opacity(
                  opacity: controller.logoOpacityAnimation.value,
                  child: Image.asset(
                    'assets/gambar/logoawal.png',
                    width: 350,
                    height: 350,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}