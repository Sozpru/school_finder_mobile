
import 'dart:io' show Platform;
import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Views/CustomWidgets/login_rounded_buttons.dart';
import 'package:e_tutor/Views/CustomWidgets/show_snackbar.dart';
import 'package:e_tutor/Views/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Helper/helper.dart';
import '../Services/my_services.dart';
import '../Utils/authentication.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'CustomWidgets/custom_dialogs.dart';
import 'CustomWidgets/custom_text_form_field.dart';
import 'bottom_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bottom_navigation_tutor.dart';

class LoginAsStudentTutor extends StatefulWidget {
  const LoginAsStudentTutor({Key? key, required bool this.isStudent})
      : super(key: key);

  final bool? isStudent;

  @override
  State<LoginAsStudentTutor> createState() => _LoginAsStudentTutorState();
}

class _LoginAsStudentTutorState extends State<LoginAsStudentTutor> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool isAndroid = false;

  TextEditingController emailCn = TextEditingController();
  TextEditingController passCn = TextEditingController();
  final ValueNotifier<bool> _counterEmail = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _counterPass = ValueNotifier<bool>(false);


  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      isAndroid = true;
      // Android-specific code
    } else if (Platform.isIOS) {
      // iOS-specific code
      isAndroid = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  ValueListenableBuilder<bool>(
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return
                          Visibility(visible : _counterEmail.value ,child: Align(alignment: Alignment.topLeft,
                              child : Text("Enter a valid Email"
                                ,style: TextStyle(fontSize: 11.sp,color: Colors.red,fontWeight: FontWeight.w400),)));
                      },valueListenable: _counterEmail),
                  const SBH5(),
                  TFF(
                    controler: emailCn,
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    align: TextAlign.start,
                    hintText: "Enter Email Address",
                    keyboardType: TextInputType.text,
                    onSaved: (data) {
                      email = data!.trim();
                    },
                    prefixIcon:  Icon(Icons.email,
                        size: 20.w,
                        color: const Color.fromARGB(100, 204, 204, 204)),
                  ),
                  const SBH10(),
                  const SBH5(),
                  const SBH1(),
                  ValueListenableBuilder<bool>(
                      builder:
                          (BuildContext context, bool value, Widget? child) {
                        return
                          Visibility(visible : _counterPass.value ,child: Align(alignment: Alignment.topLeft,
                              child : Text("Enter a valid password"
                                ,style: TextStyle(fontSize: 11.sp,color: Colors.red,fontWeight: FontWeight.w400),)));
                      },valueListenable: _counterPass),
                  const SBH5(),
                  TFF(
                    controler: passCn,
                        color: const Color.fromRGBO(61, 78, 176, 0.09),
                        align: TextAlign.start,
                        obscureText: true,
                        hintText: "Enter Password",
                        onSaved: (data) {
                          password = data!.trim();
                        },
                        prefixIcon: Icon(Icons.lock,size: 20.w,
                            color: const Color.fromARGB(100, 204, 204, 204)),

                  ),
                  const SBH10(),
                  GestureDetector(
                      onTap: () {
                        if (emailCn.text == "") {
                          showSnackBar(context, "Enter Email");
                          return;
                        } else {
                          String? email = emailCn.text;
                          CustomDialog.processDialog(
                            loadingMessage: "Processing",
                            successMessage:
                                "Password reset link sent! check your email",
                          );
                          Authentication.forgotPass(email).then((value) async {
                            if (value == null) {
                              myController.isProcessDone.value = 0;
                              myController.processErrorMessage.value =
                                  "Password reset link sent! check your email";
                            } else {
                              myController.isProcessDone.value = 0;
                              myController.processErrorMessage.value = value;
                            }
                          });
                        }
                      },
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text("Forgot Password ?",
                              style: GoogleFonts.roboto(
                                  fontSize: 13.sp,
                                  color: const Color(0xffeb9864),
                                  fontWeight: FontWeight.w400)))),
                  const SBH20(),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: appYellowButton,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            textStyle: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500)),
                        onPressed: () async {
                          formKey.currentState!.save();
                          bool isValid = formKey.currentState!.validate();
                          if(emailCn.text == ""){
                            _counterEmail.value = true;
                            return;
                          }
                          if(passCn.text == ""){
                            _counterPass.value = true;
                            return;
                          }

                          if (isValid) {
                            CustomDialog.processDialog(
                              loadingMessage: "Login",
                              successMessage: "User Logged in Successfully",
                            );
                            Authentication.loginWithEmail(email, password)
                                .then((result) async {
                              if (result == null) {
                                myController.isProcessDone.value = 2;
                                SharedPred.setIsStudent(widget.isStudent!);
                                SharedPred.setloginWith(normal);
                                if (widget.isStudent!) {
                                  studentDetail(email);
                                } else {
                                  tutorDetail(email);
                                }
                              } else {
                                myController.isProcessDone.value = 0;
                                myController.processErrorMessage.value = result;
                              }
                            });
                          }
                        },
                        child: const Text(
                          "Login",
                        ),
                      )),
                  const SBH10(),
                  Align(
                      alignment: Alignment.center,
                      child: Text("OR",
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              fontSize: 20.sp,
                              color: const Color.fromRGBO(152, 152, 152, 1)))),
                  const SBH10(),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (!isAndroid)
                      GestureDetector(
                          onTap: () {
                            String type =
                                widget.isStudent! ? "student" : "tutor";
                            // Authentication.initApple();
                            Authentication.signInWithApple().then((result) {
                              SharedPred.getToken().then((value) async {
                                CustomDialog.processDialog(
                                  loadingMessage: "Login User...",
                                  successMessage:
                                      "User Logged in Successfully",
                                );
                                final result1 = await MyServices.loginUser(
                                        username: result.displayName!,
                                        email: result.email!,
                                        userType: "apple",
                                        type: type,
                                        fcmToken: value!)
                                    .catchError(
                                  // ignore: body_might_complete_normally_catch_error
                                  (error, stackTrace) {
                                    myController.isProcessDone.value = 0;
                                    myController.processErrorMessage.value =
                                        error.toString();
                                  },
                                );
                                if (result1 != null) {
                                  if (result1.status) {
                                    myController.isProcessDone.value = 2;
                                    SharedPred.setloginWith(apple);
                                    SharedPred.setIsStudent(widget.isStudent!);
                                    SharedPred.setEmail(result.email!);
                                    if (type == "tutor") {
                                      tutorDetail(result.email!);
                                    } else {
                                      studentDetail(result.email!);
                                    }
                                  } else {
                                    myController.isProcessDone.value = 0;
                                    myController.processErrorMessage.value =
                                        result1.msg;
                                  }
                                }
                              });
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.only(left: 8.w, right: 8.w),
                              child: const LoginRoundedButton(
                                path: "assets/Images/ic_apple_.png",
                                color: 0xff393939,
                              ))),
                    GestureDetector(
                        onTap: () {
                          SharedPred.setIsStudent(widget.isStudent!);
                          String type = widget.isStudent! ? "student" : "tutor";
                          SharedPred.getToken().then((value) {
                            Authentication.signInWithGoogle(context: context)
                                .then((result) async {
                              final String? em = result?.email;
                              if (result != null) {
                                CustomDialog.processDialog(
                                  loadingMessage: "Login User...",
                                  successMessage: "User Logged in Successfully",
                                );
                                final result1 = await MyServices.loginUser(
                                        username: result.displayName!,
                                        email: em!,
                                        userType: "google",
                                        type: type,
                                        fcmToken: value!)
                                    .catchError(
                                  // ignore: body_might_complete_normally_catch_error
                                  (error, stackTrace) {
                                    myController.isProcessDone.value = 0;
                                    myController.processErrorMessage.value =
                                        error.toString();
                                  },
                                );
                                if (result1 != null) {
                                  if (result1.status) {
                                    myController.isProcessDone.value = 2;
                                    SharedPred.setloginWith(google);
                                    SharedPred.setEmail(em);
                                    if (type == "tutor") {
                                      tutorDetail(em);
                                    } else {
                                      studentDetail(em);
                                    }
                                  } else {
                                    myController.isProcessDone.value = 0;
                                    myController.processErrorMessage.value =
                                        result1.msg;
                                  }
                                }
                              }
                            });
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(left: 8.w, right: 8.w),
                            child: const LoginRoundedButton(
                              path: "assets/Images/ic_gp.png",
                              color: 0xffdb4a39,
                            ))),
                    GestureDetector(
                        onTap: () {
                          Authentication.signInWithFacebook()
                              .then((valueFB) async {

                                SharedPred.getFBSUCESS().then((value) {

                                  CustomDialog.processDialog(
                                    loadingMessage: "Login User...",
                                    successMessage: "User Logged in Successfully",
                                  );
                                  if(value) {
                                    SharedPred.getEmail().then((value) {
                                      final String em = value.toString();

                                      SharedPred.setIsStudent(
                                          widget.isStudent!);
                                      SharedPred.setloginWith(fb);
                                      String type =
                                      widget.isStudent! ? "student" : "tutor";
                                      SharedPred.getToken().then((
                                          valuetk) async {
                                        final result1 =
                                        await MyServices
                                            .loginUserWithoutusername(
                                            email: em,
                                            userType: "facebook",
                                            type: type,
                                            fcmToken: valuetk!)
                                            .catchError(
                                          // ignore: body_might_complete_normally_catch_error
                                              (error, stackTrace) {
                                            myController.isProcessDone.value =
                                            0;
                                            myController.processErrorMessage
                                                .value =
                                                error.toString();
                                          },
                                        );
                                        if (result1 != null) {
                                          if (result1.status) {
                                            myController.isProcessDone.value =
                                            2;
                                            SharedPred.setloginWith(fb);
                                            SharedPred.setEmail(em);
                                            if (type == "tutor") {
                                              tutorDetail(em);
                                            } else {
                                              studentDetail(em);
                                            }
                                          } else {
                                            myController.isProcessDone.value =
                                            0;
                                            myController.processErrorMessage
                                                .value =
                                                result1.msg;
                                          }
                                        }
                                      });
                                    });
                                  }else{

                                    myController.isProcessDone.value =
                                    0;
                                    myController.processErrorMessage
                                        .value =
                                        valueFB.toString();
                                  }
                          });
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(left: 8.w, right: 8.w),
                            child: const LoginRoundedButton(
                              path: "assets/Images/ic_fb_.png",
                              color: 0xff4267b2,
                            ))),
                  ]),
                  const SBH10(),
                  const SBH5(),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Don't have an account?",
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: const Color.fromRGBO(152, 152, 152, 1))),
                    const SBW5(),
                    GestureDetector(
                        onTap: () {
                          Get.to(() => Register(status: widget.isStudent));
                        },
                        child: Text("Register here",
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                color:
                                    const Color.fromRGBO(235, 152, 100, 1)))),
                  ])
                ],
              ),
            )),
      ],
    );
  }

  void tutorDetail(String email) async {
    final resultdetail = await MyServices.getTutorDetil().catchError(
      // ignore: body_might_complete_normally_catch_error
      (error, stackTrace) {
        myController.isProcessDone.value = 0;
        myController.processErrorMessage.value = error.toString();
      },
    );

    if (resultdetail != null) {
      if (resultdetail.data.isEmpty) {
        SharedPred.setIsTutorReg(false);
        SharedPred.setTutorDetail([]);
        SharedPred.setEmail(email);
        Get.offAll(() => const BottomNavigation());
      } else {
        SharedPred.setIsTutorReg(true);
        SharedPred.setEmail(email);
        SharedPred.setTutorDetail(resultdetail.data);
        SharedPred.setImage(resultdetail.data[0].image!);
        SharedPred.setUsername(resultdetail.data[0].username!);
        Get.offAll(() => const BottomNavigationTutor());
      }
    }
  }

  void studentDetail(String email) async {
    final resultdetail = await MyServices.studentDetail(email).catchError(
      // ignore: body_might_complete_normally_catch_error
      (error, stackTrace) {
        myController.isProcessDone.value = 0;
        myController.processErrorMessage.value = error.toString();
      },
    );

    if (resultdetail != null) {
      if (resultdetail.data == null) {
        SharedPred.setEmail(email);
        Get.offAll(() => const BottomNavigation());
      } else {
        SharedPred.setEmail(email);

        if (resultdetail.data![0].image == null) {
          SharedPred.setImage("");
        } else {
          SharedPred.setImage(resultdetail.data![0].image!);
        }

        if (resultdetail.data![0].username == null) {
          SharedPred.setUsername("");
        } else {
          SharedPred.setUsername(resultdetail.data![0].username!);
        }
        if (resultdetail.data![0].mobileNo == null) {
          SharedPred.setMobile("");
        } else {
          SharedPred.setMobile(resultdetail.data![0].mobileNo!);
        }
        if (resultdetail.data![0].standard == null) {
          SharedPred.setStd("");
        } else {
          SharedPred.setStd(resultdetail.data![0].standard!);
        }
        if (resultdetail.data![0].location == null) {
          SharedPred.setLoc("");
        } else {
          SharedPred.setLoc(resultdetail.data![0].location!);
        }
        Get.offAll(() => const BottomNavigation());
      }
    }
  }
}
