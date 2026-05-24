import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';

class RegisterStep2View extends StatelessWidget {
  const RegisterStep2View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();
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
                    // Tombol Back
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Continue registration',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Email
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Email Address',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.035)),
                        Text('Phone Number?',
                            style: TextStyle(fontSize: screenWidth * 0.03)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter email address',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: screenHeight * 0.018),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Password
                    Text('Password',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035)),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.isPasswordObscured.value,
                      decoration: InputDecoration(
                        hintText: 'Create password',
                        suffixIcon: IconButton(
                          icon: Icon(controller.isPasswordObscured.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: controller.togglePassword,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: screenHeight * 0.018),
                      ),
                    )),
                    SizedBox(height: screenHeight * 0.02),

                    // Confirm Password
                    Text('Confirm Password',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035)),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                      controller: controller.confirmPasswordController,
                      obscureText: controller.isConfirmPasswordObscured.value,
                      decoration: InputDecoration(
                        hintText: 'Re-enter password',
                        suffixIcon: IconButton(
                          icon: Icon(controller.isConfirmPasswordObscured.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: controller.toggleConfirmPassword,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: screenHeight * 0.018),
                      ),
                    )),
                    SizedBox(height: screenHeight * 0.015),

                    // Checkbox
                    Obx(() => Row(
                      children: [
                        Checkbox(
                          value: controller.isAgreed.value,
                          activeColor: const Color(0xff73090D),
                          onChanged: controller.toggleAgreed,
                        ),
                        Text('I agree with privacy policy',
                            style: TextStyle(fontSize: screenWidth * 0.035)),
                      ],
                    )),
                    SizedBox(height: screenHeight * 0.035),

                    // Tombol Sign Up
                    Obx(() => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : controller.handleRegister,
                      child: Container(
                        width: double.infinity,
                        height: screenHeight * 0.062,
                        decoration: BoxDecoration(
                          color: const Color(0xff73090D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Sign Up',
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
                        '---- Or continue with ----',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.035),
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
                      onTap: () => Get.offAllNamed('/login'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ',
                              style: TextStyle(fontSize: screenWidth * 0.035)),
                          Text(
                            'Login',
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