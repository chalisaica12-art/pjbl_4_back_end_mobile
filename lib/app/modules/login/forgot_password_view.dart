import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cek apakah controller sudah ada, jika belum buat baru
    if (!Get.isRegistered<ForgotPasswordController>()) {
      Get.put(ForgotPasswordController());
    }
    final controller = Get.find<ForgotPasswordController>();
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),

              // Tombol back
              GestureDetector(
                onTap: () {
                  // Hapus controller sebelum kembali
                  if (Get.isRegistered<ForgotPasswordController>()) {
                    Get.delete<ForgotPasswordController>();
                  }
                  Get.back();
                },
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),

              SizedBox(height: screenHeight * 0.05),

              Text(
                'Lupa Kata Sandi',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Masukkan email Anda untuk mereset kata sandi',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              Text(
                'Alamat Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.035,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat email Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: screenHeight * 0.018,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // Tombol Kirim
              Obx(() => GestureDetector(
                onTap: controller.isLoading.value ? null : controller.sendResetEmail,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.062,
                  decoration: BoxDecoration(
                    color: const Color(0xff73090D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Reset Kata Sandi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              )),

              SizedBox(height: screenHeight * 0.025),

              GestureDetector(
                onTap: () {
                  // Hapus controller sebelum kembali
                  if (Get.isRegistered<ForgotPasswordController>()) {
                    Get.delete<ForgotPasswordController>();
                  }
                  Get.back();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ingat kata sandi Anda? ',
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                    Text(
                      'Masuk',
                      style: TextStyle(
                        color: const Color(0xff73090D),
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}