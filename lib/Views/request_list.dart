import 'dart:convert';
import 'package:e_tutor/Models/hours_avail_model.dart';
import 'package:e_tutor/Views/CustomWidgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Constants/constants.dart';
import '../Constants/sharedpref.dart';
import '../Helper/helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Models/my_student_model.dart';
import '../Models/subject_model.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/handle_errors_page.dart';
import 'dart:io';

class RequestList extends StatefulWidget {
  final int type;

  const RequestList({Key? key, required this.type}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  Future<Student?>? studentData;
  String? data;
  List<SubjectDataModel> subData = [];
  List<HoursAvailData> hrsData = [];

  @override
  void initState() {
    fetchSub();
    final adUnitId = isTestMode ? Platform.isAndroid
        ? bannerAdvId
        : bannerAdvIdIos : bannerAdvIdLive;
    bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: listener,
      size: AdSize.banner,
    );
    bannerAd?.load();
    adWidget = AdWidget(ad: bannerAd!);

    super.initState();
  }

  fetchSub() {
    SharedPred.getSubjectModel().then((value) {
      subData = (json.decode(value!) as List)
          .map((data) => SubjectDataModel.fromJson(data))
          .toList();
      SharedPred.getHoursModel().then((value) {
        hrsData = (json.decode(value!) as List)
            .map((data) => HoursAvailData.fromJson(data))
            .toList();
        setState(() {
          data = "success";
        });
      });
    });
  }

  Future<Student?> fetchdata() async {
    studentData = MyServices.getMyStudentList("get_request");
    return studentData;
  }

  final AdManagerBannerAdListener listener = AdManagerBannerAdListener(
    // Called when an ad is successfully received.
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
    },
  );
  AdWidget? adWidget;
  BannerAd? bannerAd;

  @override
  void dispose() {
    // TODO: implement initState
    super.dispose();
    bannerAd!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight((size.height / 10)),
            child: AppBar(
              centerTitle: true,
              systemOverlayStyle: const SystemUiOverlayStyle(
                systemNavigationBarColor: appColor, // Navigation bar
                statusBarColor: appColor, // Status bar
              ),
              titleSpacing: 30.h,
              leading: widget.type == 0
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 25.h,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : Container(),
              title: Text(
                "Request List",
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 19.sp),
              ),
              backgroundColor: appColor,
              shape:CustomAppBarShape(multi: 0.08.h),
            )),
        body: data == null
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(10.h),
                  child: FutureBuilder<Student?>(
                      future: fetchdata(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CPI();
                        } else if (snapshot.hasError) {
                          return HandleErrorsPage(
                            errorType: snapshot.error.toString(),
                            tryAgain: () {
                              setState(() {
                                fetchdata();
                              });
                            },
                          );
                        } else if (!snapshot.data!.status) {
                          return HandleErrorsPage(
                            errorType: snapshot.data!.msg,
                          );
                        } else if (snapshot.data!.status &
                            (snapshot.data!.msg == "Data Not Found")) {
                          return HandleErrorsPage(
                            errorType: snapshot.data!.msg,
                          );
                        } else {
                          final data = snapshot.data!.data;
                          return Column(
                            children: data!.map((personone) {
                              return Slidable(
                                key: Key(personone.id!),
                                actionPane: const SlidableDrawerActionPane(),
                                actionExtentRatio: 0.15,
                                secondaryActions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        elevation: 0),
                                    child: Icon(
                                      Icons.delete_outlined,
                                      color: const Color(0xffefa289),
                                      size: 30.h,
                                    ),
                                    onPressed: () async {
                                      CustomDialog.processDialog(
                                        loadingMessage: "Deleting Request...",
                                        successMessage:
                                            "Deleting Request Successfully",
                                      );
                                      final result1 =
                                          await MyServices.reqAcceptDelete(
                                                  personone.studentEmail!,
                                                  "delete")
                                              .catchError(
                                        // ignore: body_might_complete_normally_catch_error
                                        (error, stackTrace) {
                                          myController.isProcessDone.value = 0;
                                          myController.processErrorMessage
                                              .value = error.toString();
                                        },
                                      );
                                      if (result1 != null) {
                                        if (result1.status!) {
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        } else {
                                          myController.isProcessDone.value = 0;
                                          myController.processErrorMessage
                                              .value = result1.msg!;
                                        }
                                      }
                                    },
                                  ),
                                ],
                                child: GestureDetector(
                                    onTap: () {
                                      CustomDialog.requestAcceptDialog(
                                          subData, hrsData, context, personone);
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(10.h),
                                        child: SizedBox(
                                            height: 85.h,
                                            width: double.infinity,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8.r),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.06),
                                                      offset: Offset(
                                                        0.0,
                                                        0.0,
                                                      ),
                                                      blurRadius: 10.0,
                                                      spreadRadius: 4.0,
                                                    ),
                                                  ],
                                                  color: Colors.white,
                                                ),
                                                child: Row(children: <Widget>[
                                                  Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                          padding: EdgeInsets.all(
                                                                  10.h),
                                                          child: Container(
                                                              height: 60.h,
                                                              width: 60.w,
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Card(
                                                                  elevation: 0,
                                                                  semanticContainer:
                                                                      true,
                                                                  clipBehavior: Clip
                                                                      .antiAliasWithSaveLayer,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.r),
                                                                  ),
                                                                  color: Colors
                                                                      .white,
                                                                  child: Image.network(
                                                                      personone
                                                                          .image!,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) =>
                                                                          Image.asset(
                                                                              'assets/Images/ic_avtar.png')))))),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Text(
                                                              personone
                                                                  .username!,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts
                                                                  .roboto(
                                                                      fontSize:
                                                                          19.sp,
                                                                      color: const Color
                                                                          .fromRGBO(
                                                                        98,
                                                                        98,
                                                                        98,
                                                                        1,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)),
                                                          const SBH5(),
                                                          Text(
                                                              getSringfromSubjectArray(
                                                                  personone
                                                                      .subject!,
                                                                  subData),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  fontSize: 17.sp,
                                                                  color: const Color
                                                                          .fromRGBO(
                                                                      152,
                                                                      152,
                                                                      152,
                                                                      1))),
                                                        ],
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Padding(
                                                          padding: EdgeInsets
                                                                      .only(
                                                                  right: 5.w),
                                                          child:
                                                              GestureDetector(
                                                                  onTap:
                                                                      () async {
                                                                        if(personone.status == "accept"){
                                                                          CustomDialog.requestAcceptDialog(
                                                                              subData, hrsData, context, personone);
                                                                        }else{
                                                                    CustomDialog
                                                                        .processDialog(
                                                                      loadingMessage:
                                                                          "Accepting Request...",
                                                                      successMessage:
                                                                          "Accepting Request Successfully",
                                                                    );
                                                                    final result1 = await MyServices.reqAcceptDelete(
                                                                            personone.studentEmail!,
                                                                            "accept")
                                                                        .catchError(
                                                                      (error,
                                                                          // ignore: body_might_complete_normally_catch_error
                                                                          stackTrace) {
                                                                        myController
                                                                            .isProcessDone
                                                                            .value = 0;
                                                                        myController
                                                                            .processErrorMessage
                                                                            .value = error.toString();
                                                                      },
                                                                    );
                                                                    if (result1 !=
                                                                        null) {
                                                                      if (result1
                                                                          .status!) {
                                                                        setState(
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          //refresh UI after deleting element from list
                                                                        });
                                                                      } else {
                                                                        myController
                                                                            .isProcessDone
                                                                            .value = 0;
                                                                        myController
                                                                            .processErrorMessage
                                                                            .value = result1.msg!;
                                                                      }
                                                                    }
                                                                        }
                                                                  },
                                                                  child: Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            85.w,
                                                                        height:
                                                                            35.h,
                                                                        child: Card(
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                                                            color: const Color.fromRGBO(87, 155, 119, 1),
                                                                            elevation: 0,
                                                                            child: Align(alignment: Alignment.center, child: Text(personone.status == "accept" ? "Detail" :"Accept", style: GoogleFonts.roboto(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Colors.white)))),
                                                                      ))))),
                                                ]))))),
                              );
                            }).toList(),
                          );
                        }
                      }),
                ),
              ),
        bottomNavigationBar: BottomAppBar(child: Container(
          alignment: Alignment.center,
          width: bannerAd!.size.width.toDouble(),
          height: bannerAd!.size.height.toDouble(),
          child: adWidget,
        )));
  }
}
