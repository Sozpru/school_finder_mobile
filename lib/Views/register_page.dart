
// ignore_for_file: must_be_immutable

import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Constants/sharedpref.dart';
import '../Helper/helper.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/custom_dialogs.dart';
import 'CustomWidgets/custom_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:e_tutor/Utils/authentication.dart';
import 'CustomWidgets/show_snackbar.dart';

class Register extends StatefulWidget {
  Register({Key? key, required this.status}) : super(key: key);

  bool? status;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = GlobalKey<FormState>();
  String username = "";
  String email = "";
  String password = "", rePassword = "";

  TextEditingController userCn = TextEditingController();
  TextEditingController emailCn = TextEditingController();
  TextEditingController passCn = TextEditingController();
  TextEditingController repassCn = TextEditingController();
  final ValueNotifier<bool> _counterUser = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _counterEmail = ValueNotifier<bool>(false);
  final ValueNotifier<String> _counterValidEmail = ValueNotifier<String>("");
  final ValueNotifier<bool> _counterPass = ValueNotifier<bool>(false);
  final ValueNotifier<String> _counterPassStr = ValueNotifier<String>("Enter Password");
  final ValueNotifier<String> _counterrePassStr = ValueNotifier<String>("");
  final ValueNotifier<bool> _counterrePass = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight((size.height / 10)),
            child: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                systemNavigationBarColor: appColor, // Navigation bar
                statusBarColor: appColor, // Status bar
              ),
              titleSpacing: 30.h,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 25.h,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: widget.status!
                  ? Text(
                      "Register as User",
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 19.sp),
                    )
                  : Text(
                      "Register as School",
                      style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 19.sp),
                    ),
              backgroundColor: appColor,
              shape: CustomAppBarShape(multi: 0.08.h),
            )),
        body: ListView(
          children: [
            const SBH10(),
            const SBH5(),
            Align(
              alignment: Alignment.center,
              child: Image.asset("assets/Images/ic_inter.png", height: 140.h),
            ),
            const SBH10(),
            const SBH5(),
            Padding(
                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      ValueListenableBuilder<bool>(
                          builder: (BuildContext context, bool value,
                              Widget? child) {
                            return Visibility(
                                visible: _counterUser.value,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Enter a Username",
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w400),
                                    )));
                          },
                          valueListenable: _counterUser),
                      const SBH5(),
                      TFF(
                        controler: userCn,
                        color: const Color.fromRGBO(61, 78, 176, 0.09),
                        align: TextAlign.center,
                        hintText: "User Name",
                        keyboardType: TextInputType.text,
                        onSaved: (data) {
                          username = data!.trim();
                        },
                      ),
                      const SBH10(),
                      const SBH5(),
                      ValueListenableBuilder<bool>(
                          builder: (BuildContext context, bool value,
                              Widget? child) {
                            return Visibility(
                                visible: _counterEmail.value,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child:ValueListenableBuilder<String>(
    builder: (BuildContext context, String value,
    Widget? child) {
    return Text(
                                      _counterValidEmail.value,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w400),
                                    );},
                                        valueListenable: _counterValidEmail)));
                          },
                          valueListenable: _counterEmail),
                      const SBH5(),
                      TFF(
                        controler: emailCn,
                        color: const Color.fromRGBO(61, 78, 176, 0.09),
                        align: TextAlign.center,
                        hintText: "Enter Email Address",
                        keyboardType: TextInputType.text,
                        onSaved: (data) {
                          email = data!.trim();
                        },
                      ),
                      const SBH10(),
                      const SBH5(),
                      ValueListenableBuilder<bool>(
                          builder: (BuildContext context, bool value,
                              Widget? child) {
                            return Visibility(
                                visible: _counterPass.value,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: ValueListenableBuilder<String>(
    builder: (BuildContext context, String value,
    Widget? child) {
    return Text(
                                      _counterPassStr.value,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w400),
                                    );},
                            valueListenable: _counterPassStr)));},
                          valueListenable: _counterPass),
                      const SBH5(),
                      TFF(
                        controler: passCn,
                        color: const Color.fromRGBO(61, 78, 176, 0.09),
                        align: TextAlign.center,
                        obscureText: true,
                        hintText: "Password",
                        onSaved: (data) {
                          password = data!.trim();
                        },
                      ),
                      const SBH10(),
                      const SBH5(),

                      ValueListenableBuilder<bool>(
                          builder: (BuildContext context, bool value,
                              Widget? child) {
                            return Visibility(
                                visible: _counterrePass.value,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: ValueListenableBuilder<String>(
    builder: (BuildContext context, String value,
    Widget? child) {
    return Text(
                                      _counterrePassStr.value,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.red,
                                          fontWeight: FontWeight.w400),
                                    );},
                                        valueListenable: _counterrePassStr)));
                          },
                          valueListenable: _counterrePass),
                      const SBH5(),
                      TFF(
                        controler: repassCn,
                        color: const Color.fromRGBO(61, 78, 176, 0.09),
                        align: TextAlign.center,
                        obscureText: true,
                        hintText: "Re-enter Password",
                        onSaved: (data) {
                          rePassword = data!.trim();
                        },
                      ),
                      const SBH20(),
                      const SBH20(),
                      const SBH20(),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: appYellowButton,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)),
                                textStyle: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500)),
                            onPressed: () async {
                              formKey.currentState!.save();
                              bool isValid = formKey.currentState!.validate();
                              if(userCn.text == ""){
                                _counterUser.value = true;
                                return;
                              }else{
                                _counterUser.value = false;
                              }
                              if(emailCn.text == ""){
                                _counterEmail.value = true;
                                _counterValidEmail.value = "Enter Email";
                                return;
                              }else{
                                _counterEmail.value = false;
                              }

                              final bool emailValid = RegExp(
                                  r"^[a-zA-Z0\d.a-zA-Z!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z\d]+\.[a-zA-Z]+")
                                  .hasMatch(email);
                              if (!emailValid) {
                                _counterEmail.value = true;
                                _counterValidEmail.value = "Enter Valid Email";
                                return;
                              }else{
                                _counterEmail.value = false;
                                _counterValidEmail.value= "";
                              }
                              if(passCn.text == ""){
                                _counterPass.value = true;
                                _counterPassStr.value = "Enter a Password";
                                return;
                              }else{
                                _counterPass.value = false;
                              }

                              if(passCn.text.length < 8){
                                _counterPass.value = true;
                                _counterPassStr.value = "Password must be 8 or more than long";
                                return;
                              }else{
                                _counterPass.value = false;
                                _counterPassStr.value = "";
                              }
                              if(repassCn.text == ""){
                                _counterrePass.value = true;
                                _counterrePassStr.value = "Enter a Password";
                                return;
                              }else{
                                _counterrePassStr.value = "";
                                _counterrePass.value = false;
                              }

                              if(password != rePassword){
                                _counterrePass.value = true;
                                _counterrePassStr.value = "Re-enter Password is not matched with Password";
                                return;
                              }else{
                                _counterrePass.value = false;
                                _counterrePassStr.value = "";
                              }

                              if (isValid) {
                                CustomDialog.processDialog(
                                  loadingMessage: "Register ...",
                                  successMessage:
                                      "User Registered in Successfully",
                                );
                                SharedPred.getToken().then((value) {
                                  Authentication()
                                      .signUp(
                                          email: email,
                                          password: password,
                                          context: context)
                                      .then((result) async {
                                    if (result == null) {
                                      FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                      if(!mounted) return;
                                      showSnackBar(context, "Email verification sent! Please check your email and verify then login");
                                      Get.offAll(
                                              () => const LoginPage());
                                    } else {
                                      myController.isProcessDone.value = 0;
                                      myController.processErrorMessage.value =
                                          result;
                                    }
                                  });
                                });
                              }
                            },
                            child: const Text(
                              "Register",
                            ),
                          )),
                      const SBH20(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?",
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                    color: const Color.fromRGBO(
                                        152, 152, 152, 1))),
                            const SBW5(),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          const LoginPage(),
                                    ),
                                    (route) =>
                                        false, //if you want to disable back feature set to false
                                  );
                                },
                                child: Text("Login",
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                        color: const Color.fromRGBO(
                                            235, 152, 100, 1)))),
                          ]),
                      const SBH20()
                    ],
                  ),
                )),
          ],
        ));
  }
}
