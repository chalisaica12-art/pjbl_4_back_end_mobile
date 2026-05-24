import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> logoOpacityAnimation;

  @override
  void onInit() {
    super.onInit();
    _initAnimation();
  }

  void _initAnimation() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    scaleAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed(Routes.LOGIN);
        });
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}