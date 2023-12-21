import 'package:e_tutor/Views/about.dart';
import 'package:e_tutor/Views/tutor_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Askme/ask_me.dart';
import '../../Constants/constants.dart';
import '../../Constants/sharedpref.dart';
import '../../Helper/helper.dart';
import '../login_page.dart';
import '../my_student.dart';
import '../request_list.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawerTutor extends StatefulWidget {
  const CustomDrawerTutor({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawerPatientState createState() => _DrawerPatientState();
}

class _DrawerPatientState extends State<CustomDrawerTutor> {
  static String data = "";
  static String img = "", username = "";
  static bool isREg = false;

  @override
  void initState() {
    super.initState();
    callAsyncFetch();
  }

  Future callAsyncFetch() async {
    SharedPred.getIsTutorReg().then((value) {
      isREg = value!;
    SharedPred.getImage().then((value) {
      img = value;
      SharedPred.getUsername().then((value) {
        username = value;
        setState(() {
          data = "success";
        });
      });
    });
    });
  }

  @override
  Widget build(BuildContext context) {
    return data == ""
        ? const CircularProgressIndicator()
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Drawer(
              backgroundColor: appDrawerColor,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Stack(
                    children: [
                      Container(
                          color: const Color.fromRGBO(238, 239, 248, 1),
                          child: Column(
                            children: [
                              const SBH20(),
                              if (img == "")
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: const AssetImage(
                                      "assets/Images/ic_avtar.png"),
                                  radius: 50.r,
                                ),
                              if (img != "")
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(img),
                                  radius: 50.r,
                                ),
                              const SBH20(),
                              Center(
                                child: Text(
                                  'Hi, $username',
                                  style: GoogleFonts.roboto(
                                      fontSize: 16.sp,
                                      color:
                                          const Color.fromRGBO(52, 94, 168, 1),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SBH10(),
                              Divider(
                                color: appColor,
                                thickness: 3.h,
                                height: 1.h,
                              ),
                            ],
                          ))
                    ],
                  ),
                  !isREg ? CustomListTile(
                    title: "Home",
                    leadingIcon: Icons.home_rounded,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ) : Container(),
                  !isREg ? Divider(
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    thickness: 1.h,
                    height: 1.h,
                  ) : Container(),
                  CustomListTile(
                    title: "Request List",
                    leadingIcon: Icons.group,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const RequestList(type: 0));
                    },
                  ),
                  Divider(
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    thickness: 1.h,
                    height: 1.h,
                  ),
                  CustomListTile(
                    title: "My Student",
                    leadingIcon: Icons.group,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const MyStudentList());
                    },
                  ),
                  Divider(
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    thickness: 1.h,
                    height: 1.h,
                  ),
                  Divider(
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    thickness: 1.h,
                    height: 1.h,
                  ),
                  CustomListTile(
                    title: "Ask Me",
                    leadingIcon: Icons.question_mark_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const AskMe());
                    },
                  ),
                  CustomListTile(
                    title: "My Profile",
                    leadingIcon: Icons.person,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => const TutorProfile(type: 0));
                    },
                  ),
                  Divider(
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    thickness: 1.h,
                    height: 1.h,
                  ),
                  CustomListTile(
                    title: "About us",
                    leadingIcon: Icons.info,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(
                        () => const AboutUs(s: "About us", type: 0),
                        // RequestList()
                        // TutorProfile()
                      );
                    },
                  ),
                  Divider(
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    thickness: 1.h,
                    height: 1.h,
                  ),
                  CustomListTile(
                    title: "Privacy Policy",
                    leadingIcon: Icons.privacy_tip_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(
                        () => const AboutUs(s: "Privacy Policy", type: 1),
                      );
                    },
                  ),
                  Divider(
                    color: const Color.fromRGBO(61, 78, 176, 0.09),
                    thickness: 1.h,
                    height: 1.h,
                  ),
                  CustomListTile(
                    title: "Logout",
                    leadingIcon: Icons.logout_rounded,
                    onTap: () {
                      myController.logout();
                      Get.offAll(
                        () => const LoginPage(),
                      );
                    },
                  ),
                ],
              ),
            ));
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key? key,
    this.onTap,
    required this.leadingIcon,
    required this.title,
  }) : super(key: key);
  final GestureTapCallback? onTap;
  final IconData leadingIcon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 0,
      leading: Icon(
        leadingIcon,
        color: const Color(0xffcccccc),
        size: 24.sp,
      ),
      title: Text(
        title,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w400,
          color: appColor,
          fontSize: 18.sp,
        ),
      ),
    );
  }
}
