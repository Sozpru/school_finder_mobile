import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Utils/authentication.dart';
import 'package:get/get.dart';

class MyController extends GetxController {
  var isProcessDone = 1.obs;
  var processErrorMessage = "".obs;

  List<String> options = [];
  Rx<List<String>> select = Rx<List<String>>([]);
  var selOpt = ''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  Future<void> logout() async {
    SharedPred.setImage("");
    SharedPred.setEmail("");
    SharedPred.setUsername("");
    SharedPred.setIsStudent(false);
    SharedPred.setTutorDetail([]);
    SharedPred.setloginWith(0);
    SharedPred.setIsTutorReg(false);
    Authentication.signOut();
  }
}
