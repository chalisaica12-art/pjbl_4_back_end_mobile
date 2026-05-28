import 'package:get/get.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // Controller akan dibuat di view, bukan di binding
    // Ini untuk menghindari duplicate controller
  }
}