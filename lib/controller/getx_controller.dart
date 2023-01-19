import 'package:get/get.dart';

class CanalController extends GetxController {
  final count = 0.obs;

  @override
  void onInit() {
    String canal = '';
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  void increment() => count.value++;
}
