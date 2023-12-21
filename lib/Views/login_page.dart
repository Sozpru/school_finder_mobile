
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Constants/constants.dart';
import '../Helper/helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_bottom.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  int initalIndex = 0;
  bool isStudent = true;

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
            titleSpacing: 30.w,
            backgroundColor: appColor,
            shape: CustomAppBarShape(multi: 0.08.h),
          )),
      body: ListView(
        children: <Widget>[
          const SBH20(),
          Align(
            alignment: Alignment.center,
            child: Image.asset("assets/Images/ic_inter.png", height: 135.h,fit: BoxFit.cover,)),
          const SBH10(),
          Align(
              alignment: Alignment.topCenter,
              child: Text("Login as",
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: const Color.fromRGBO(152, 152, 152, 1)))),
          const SBH7(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              children: [
                Container(
                    height: 50.h,
                    margin: EdgeInsets.symmetric(horizontal: 18.h),
                    decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.circular(50.r),
                      border: Border.all(
                        color: appColorS100,
                        width: 5.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    initalIndex = 0;
                                    isStudent = true;
                                  });
                                },
                                child: Container(
                                  height: 45.h,
                                  decoration: BoxDecoration(
                                    color: initalIndex == 0 ? Colors.white : appColor,
                                    borderRadius: BorderRadius.circular(50.r),
                                    border: Border.all(
                                      color: initalIndex == 0
                                          ? Colors.white
                                          : appColor,
                                      width: 5.w,
                                    ),
                                  ),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "User",
                                        style: GoogleFonts.roboto(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: initalIndex == 1 ? appWhite : const Color.fromRGBO(152, 152, 152, 1)),
                                      )),
                                ))),
                        Expanded(
                            flex: 2,
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    initalIndex = 1;
                                    isStudent = false;
                                  });
                                },
                                child: Container(
                                  height: 45.h,
                                  decoration: BoxDecoration(
                                    color: initalIndex == 1
                                        ? Colors.white
                                        : appColor,
                                    borderRadius: BorderRadius.circular(50.r),
                                    border: Border.all(
                                      color: initalIndex == 1
                                          ? Colors.white
                                          : appColor,
                                      width: 5.w,
                                    ),
                                  ),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "School",
                                        style: GoogleFonts.roboto(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: initalIndex == 0
                                                ? appWhite
                                                : const Color.fromRGBO(
                                                    152, 152, 152, 1)),
                                      )),
                                ))),
                      ],
                    )
                    // child: TabBar(
                    //   isScrollable: false,
                    //   physics: const BouncingScrollPhysics(),
                    //   labelPadding: EdgeInsets.zero,
                    //   labelColor: appgreyHomeText,
                    //   unselectedLabelColor: Colors.white,
                    //   labelStyle: GoogleFonts.roboto(
                    //     color: appgreyHomeText,
                    //     fontWeight: FontWeight.w500,
                    //     fontSize: 18
                    //   ),
                    //   unselectedLabelStyle: GoogleFonts.roboto(color:const Color.fromRGBO(152, 152, 152, 1),fontSize: 18,
                    //       fontWeight: FontWeight.w500),
                    //   indicator: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(50),
                    //   ),
                    //   tabs: const [
                    //     Tab(
                    //       text: "Student",
                    //     ),
                    //     Tab(
                    //       text: "Tutor",
                    //     ),
                    //   ],
                    // ),
                    ),
              ],
            ),
          ),
          LoginAsStudentTutor(isStudent: isStudent)
          // create widgets for each tab bar here
          // const Expanded(
          //   child: TabBarView(
          //     children: [
          //       LoginAsStudentTutor(isStudent : true),
          //       LoginAsStudentTutor(isStudent : false)
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
