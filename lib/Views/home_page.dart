import 'package:e_tutor/Views/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../Constants/constants.dart';
import '../Helper/helper.dart';
import 'CustomDrawer/custom_drawer.dart';
import 'home_near_by.dart';
import 'home_tab_detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, //or set color with: Color(0xFF0000FF)
    ));
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "School Finder",
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
                color: const Color.fromRGBO(57, 57, 57, 1)),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.notes_rounded,
                color: appColor,
                size: 25.h,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: <Widget>[
            Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      Get.to(() => const NotificationPage());
                    },
                    icon: Icon(
                      Icons.notifications,
                      color: appColor,
                      size: 25.h,
                    )))
          ],
        ),
        drawer: const CustomDrawer(),
        body: AnnotatedRegion(
            value: const SystemUiOverlayStyle(statusBarColor: appColor),
            child: DefaultTabController(
                length: 3,
                child: Column(
                  children: <Widget>[
                    const SBH10(),
                    Column(
                      children: [
                        Container(
                          height: 39.h,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(249, 249, 255, 1),
                          ),
                          child: TabBar(
                            tabs: [
                              Row(children: [
                                Icon(
                                  Icons.list_alt_sharp,
                                  size: 23.h,
                                ),
                                Text(
                                  "  All",
                                  style: GoogleFonts.roboto(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                )
                              ]),
                              Row(children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 23.h,
                                ),
                                Text(
                                  " Nearby",
                                  style: GoogleFonts.roboto(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                )
                              ]),
                              Row(children: [
                                Icon(
                                  Icons.star,
                                  size: 23.h,
                                ),
                                Text(
                                  " Popular",
                                  style: GoogleFonts.roboto(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400),
                                )
                              ]),
                            ],
                            unselectedLabelColor:
                                const Color.fromRGBO(152, 152, 152, 1),
                            labelColor: appColor,
                            indicatorColor:
                                const Color.fromRGBO(246, 189, 96, 1),
                            indicatorWeight: 4.h,
                          ),
                        ),
                      ],
                    ),
                    // create widgets for each tab bar here
                    const Expanded(
                      child: TabBarView(
                        children: [
                          HomeDetailTabDetail(0, "All Schools"),
                          HomeNearBy("Nearby School"),
                          HomeDetailTabDetail(1, "Popular School")
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}
