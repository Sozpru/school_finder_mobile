import 'package:get/get.dart';
import '../Controller/my_controller.dart';


class MyBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MyController());
  }
}
