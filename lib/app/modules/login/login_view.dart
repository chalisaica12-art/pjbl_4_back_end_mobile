import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import 'forgot_password_view.dart';
import 'forgot_password_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.06),
                    Text(
                      'Masuk ke Akun',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Selamat Datang Kembali!',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Email
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
                        hintText: 'Masukkan alamat email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: screenHeight * 0.018,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Password
                    Text(
                      'Kata Sandi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.isPasswordObscured.value,
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi',
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordObscured.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: controller.togglePassword,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: screenHeight * 0.018,
                        ),
                      ),
                    )),

                    // Lupa Password
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Hapus controller lama jika ada
                          if (Get.isRegistered<ForgotPasswordController>()) {
                            Get.delete<ForgotPasswordController>();
                          }
                          Get.to(() => const ForgotPasswordView());
                        },
                        child: Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    // Checkbox
                    Obx(() => Row(
                      children: [
                        Checkbox(
                          value: controller.isAgreed.value,
                          activeColor: const Color(0xff73090D),
                          onChanged: controller.toggleAgreed,
                        ),
                        Text(
                          'Saya menyetujui kebijakan privasi',
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        ),
                      ],
                    )),
                    SizedBox(height: screenHeight * 0.035),

                    // Tombol Login
                    Obx(() => GestureDetector(
                      onTap: controller.isLoading.value ? null : controller.handleLogin,
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
                                  'Masuk',
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

                    Center(
                      child: Text(
                        '---- Atau masuk dengan ----',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Ikon Sosial Media
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset('assets/gambar/icongoogle.png',
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08),
                        ),
                        SizedBox(width: screenWidth * 0.07),
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset('assets/gambar/iconfacebook.png',
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08),
                        ),
                        SizedBox(width: screenWidth * 0.07),
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset('assets/gambar/iconapple.png',
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),
                    GestureDetector(
                      onTap: () => Get.toNamed('/register'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(fontSize: screenWidth * 0.035),
                          ),
                          Text(
                            'Daftar',
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
          ),
        ],
      ),
    );
  }
}