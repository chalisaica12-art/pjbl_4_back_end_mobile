import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterStep1View extends StatelessWidget {
  const RegisterStep1View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.delete<RegisterController>(force: true);
                  Get.offAllNamed('/login');
                },
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text('Buat Akun',
                  style: TextStyle(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold)),
              Text('Informasi Pribadi',
                  style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black)),
              SizedBox(height: screenHeight * 0.05),

              Text('Nama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: screenHeight * 0.018),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              Text('Nomor Telepon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)),
              const SizedBox(height: 8),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor telepon',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: screenHeight * 0.018),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

              GestureDetector(
                onTap: controller.handleNext,
                child: Container(
                  width: double.infinity,
                  height: screenHeight * 0.062,
                  decoration: BoxDecoration(
                    color: const Color(0xff73090D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('Selanjutnya',
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              GestureDetector(
                onTap: () {
                  Get.delete<RegisterController>(force: true);
                  Get.offAllNamed('/login');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ', style: TextStyle(fontSize: screenWidth * 0.035)),
                    Text('Masuk',
                        style: TextStyle(color: const Color(0xff73090D), fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035)),
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