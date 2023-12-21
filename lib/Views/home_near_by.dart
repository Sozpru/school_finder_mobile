import 'dart:async';
import 'dart:convert';
import 'package:e_tutor/Models/standard.dart';
import 'package:e_tutor/Views/tutor_detail_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Constants/constants.dart';
import '../Constants/sharedpref.dart';
import '../Helper/helper.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/subject_model.dart';
import '../Models/tutor_model.dart';
import '../Services/my_services.dart';
import 'package:geolocator/geolocator.dart';
import 'CustomWidgets/handle_errors_page.dart';
import 'CustomWidgets/show_snackbar.dart';

class HomeNearBy extends StatefulWidget {
  final String? text;

  const HomeNearBy(this.text, {super.key});

  @override
  HomeNearByState createState() => HomeNearByState();
}

class HomeNearByState extends State<HomeNearBy>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<TutorModel?>? tutorData;
  List<SubjectDataModel> subData = [];
  List<StandardDataModel?>? stdData;
  String? data;
  String? _data;
  Position? aa;

  @override
  void initState() {
    super.initState();
    fetchInitial();
  }

  fetchInitial() async {
    SharedPred.getSubjectModel().then((value) {
      setState(() {
        subData = (json.decode(value!) as List)
            .map((data) => SubjectDataModel.fromJson(data))
            .toList();
        SharedPred.getStandardModel().then((value) async {
          stdData = (json.decode(value!) as List)
              .map((data) => StandardDataModel.fromJson(data))
              .toList();
          data = "success";
          fetchData();
        });
      });
    });
  }

  fetchData() async {
    subName.clear();
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
    } else if (permission == LocationPermission.deniedForever) {
    } else {
      try {
        Geolocator.getCurrentPosition().then((value) {
          tutorData = MyServices.getTutorListNearby(
              lat: value.latitude.toString(), long: value.longitude.toString());
          setState(() {
            _data = "succ";
          });
        });
      } catch (e) {
        _data = null;
      }
    }
  }

  void fetchBySubject(String subject) {
    tutorData = MyServices.getTutorBySubject(subject);
    setState(() {});
  }


  List<String> subName = [];

  var colors = [
    const Color.fromRGBO(239, 162, 137, 1),
    const Color.fromRGBO(136, 209, 240, 1),
    const Color.fromRGBO(179, 154, 229, 1),
  ];

  var colorsIcon = [
    const Color.fromRGBO(208, 95, 58, 1),
    const Color.fromRGBO(74, 169, 209, 1),
    const Color.fromRGBO(142, 131, 213, 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        const SBH10(),
        const SBH5(),
        // construct the profile details widget here
        data == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
                child: SizedBox(
                    height: 100.h,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: subData.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              var distIdsCh = subName.toSet().toList();
                              if (distIdsCh.length > 2 &&
                                  !subData[index].isSelected) {
                                showSnackBar(context,
                                    'Maximum 3 subject selection are allowed');
                              } else {
                                subData[index].isSelected
                                    ? subName.remove(subData[index].id!)
                                    : subName.add(subData[index].id!);
                                subData[index].isSelected =
                                    !subData[index].isSelected;
                                var distIds = subName.toSet().toList();
                                var ss = distIds.join(",");
                                if (ss == "") {
                                  fetchData();
                                  setState(() {});
                                } else {
                                  fetchBySubject(ss);
                                }
                              }
                            },
                            child: SizedBox(
                                height: 100.h,
                                width: 150.w,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.r)),
                                    margin: EdgeInsets.only(
                                        left: 10.w, right: 10.w),
                                    elevation: 0,
                                    color: colors[index % 3],
                                    child: Column(children: [
                                      Visibility(
                                          maintainSize: true,
                                          maintainAnimation: true,
                                          maintainState: true,
                                          visible: subData[index].isSelected,
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                  padding: const EdgeInsets.all(7),
                                                  child: ClipOval(
                                                    child: Material(
                                                      color: colorsIcon[
                                                          index % 3],
                                                      // Button color
                                                      child: InkWell(
                                                        onTap: () {},
                                                        child: SizedBox(
                                                            width: 16.w,
                                                            height: 16.h,
                                                            child: Icon(
                                                              Icons.check,
                                                              size: 10.17.h,
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                      ),
                                                    ),
                                                  )))),
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(subData[index].image!,
                                                // color: colors_icon[index % 3],
                                                width: 30.w,
                                                height: 30.h,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                      'assets/Images/ic_placeholder.png',
                                                      width: 30.w,
                                                    )),
                                            const SBH5(),
                                            Text(subData[index].subjectName!,maxLines: 1,overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 20.sp,
                                                    color: Colors.white))
                                          ])
                                    ]))));
                      },
                    ))),
        const SBH10(),
        Expanded(
            child: Column(
          children: [
            Expanded(
                child: Container(
                    // height: 250,
                    width: double.infinity,
                    color: const Color.fromRGBO(249, 249, 255, 1),
                    child: Padding(
                        padding: EdgeInsets.all(5.h),
                        child: Column(children: <Widget>[
                          const SBH10(),
                          Row(children: [
                            const SBW5(),
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(widget.text!,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.sp,
                                        color: const Color.fromRGBO(
                                            152, 152, 152, 1))))
                          ]),
                          const SBH10(),
                          _data == null
                              ? const CircularProgressIndicator()
                              : Expanded(
                                  child: FutureBuilder<TutorModel?>(
                                      future: tutorData,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CPI();
                                        } else if (snapshot.hasError) {
                                          return HandleErrorsPage(
                                            errorType:
                                                snapshot.error.toString(),
                                            tryAgain: () {
                                              setState(() {
                                                fetchData();
                                              });
                                            },
                                          );
                                        } else if (!snapshot.data!.status) {
                                          return HandleErrorsPage(
                                            errorType: snapshot.data!.msg,
                                          );
                                        } else if (snapshot.data!.status &
                                            (snapshot.data!.msg ==
                                                "Data Not Found")) {
                                          return HandleErrorsPage(
                                            errorType: snapshot.data!.msg,
                                          );
                                        } else {
                                          final data = snapshot.data!.data;
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            itemCount: data!.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Get.to(() => TutorDetail(
                                                        data[index].email!,
                                                        stdData,
                                                        subData,
                                                      ));
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                          top: 10.h,
                                                          bottom: 10.h,
                                                          right: 5.w,
                                                          left: 5.w),
                                                  child: SizedBox(
                                                    height: 80.h,
                                                    width: double.infinity,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(13.r),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color:
                                                                Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.04),
                                                            offset: Offset(
                                                              0.0,
                                                              0.0,
                                                            ),
                                                            blurRadius: 3.0,
                                                            spreadRadius: 3.0,
                                                          ),
                                                        ],
                                                        color: Colors.white,
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const SBW10(),
                                                          CircleAvatar(
                                                              radius: 28.r,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              child: ClipOval(
                                                                child: Image.network(
                                                                    data[index]
                                                                        .image!,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Image.asset(
                                                                            'assets/Images/ic_avtar.png')),
                                                              )),
                                                          const SBW10(),
                                                          Expanded(
                                                              child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                .stretch,
                                                            children: [
                                                              Text(
                                                              data[index]
                                                                  .username!,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                      fontSize:
                                                                          16.sp,
                                                                      color: const Color
                                                                          .fromRGBO(
                                                                        98,
                                                                        98,
                                                                        98,
                                                                        1,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight.w500)),
                                                              const SBH5(),
                                                              Text(
                                                              getSringfromSTDArray(
                                                                  data[index]
                                                                      .standard!,
                                                                  stdData),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: const Color
                                                                          .fromRGBO(
                                                                      116,
                                                                      115,
                                                                      144,
                                                                      1))),
                                                              const SBH5(),
                                                              Text(
                                                              getSringfromSubjectArray(
                                                                  data[index]
                                                                      .subject!,
                                                                  subData),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.roboto(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: const Color
                                                                          .fromRGBO(
                                                                      152,
                                                                      152,
                                                                      152,
                                                                      1),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300)),
                                                            ],
                                                          )),
                                                          Padding(padding: EdgeInsets
                                                                      .all(10.h),
                                                              child: Column(
                                                                children: [
                                                                  Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .topRight,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.my_location_rounded,
                                                                            color: const Color(0xffc4c4c4),
                                                                            size: 16.h,
                                                                          ),
                                                                          const SBW5(),
                                                                          Text(
                                                                              "${data[index].distance!} km",
                                                                              style: GoogleFonts.roboto(
                                                                                  fontWeight: FontWeight.w300,
                                                                                  fontSize: 15.sp,
                                                                                  color: const Color.fromRGBO(152, 152, 152, 1)))
                                                                        ],
                                                                      ))
                                                                ],
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }))
                        ]))))
          ],
        ))
      ],
    );
  }
}
