import 'package:get/get.dart';
import 'login_controller.dart';
import 'forgot_password_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(LoginController());
    Get.put<ForgotPasswordController>(ForgotPasswordController());
  }
}