import 'dart:convert';

import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Models/hours_avail_model.dart';
import 'package:e_tutor/Models/subject_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Chat/chat_page.dart';
import '../Helper/helper.dart';
import '../Models/my_tutor_model.dart';
import '../Models/standard.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/custom_dialogs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CustomWidgets/handle_errors_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

class MyTutorListPage extends StatefulWidget {
  const MyTutorListPage({Key? key}) : super(key: key);

  @override
  State<MyTutorListPage> createState() => _MyTutorListPageState();
}

class _MyTutorListPageState extends State<MyTutorListPage> {
  Future<MyTutorModel?>? tutorData;
  List<SubjectDataModel> subData = [];
  List<HoursAvailData> hrsData = [];
  List<StandardDataModel> stdData = [];
  String? data;

  final AdManagerBannerAdListener listener = AdManagerBannerAdListener(
    // Called when an ad is successfully received.
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
    },
    // Called when an ad opens an overlay that covers the screen.
    // Called when an ad removes an overlay that covers the screen.
    // Called when an impression occurs on the ad.
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
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
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
  }

  String searchString = "";

  void fetchdata() {
    SharedPred.getSubjectModel().then((value) {
      subData = (json.decode(value!) as List)
          .map((data) => SubjectDataModel.fromJson(data))
          .toList();

      SharedPred.getHoursModel().then((value) {
        hrsData = (json.decode(value!) as List)
            .map((data) => HoursAvailData.fromJson(data))
            .toList();
        SharedPred.getStandardModel().then((value) {
          stdData = (json.decode(value!) as List)
              .map((data) => StandardDataModel.fromJson(data))
              .toList();
          fetchmyTutorData();
        });
      });
    });
  }

  void fetchmyTutorData() {
    setState(() {
      tutorData = MyServices.getMyTutorList("my_tutor");
      data = "success";
    });
  }

  @override
  Widget build(BuildContext context) {
    PaintingBinding.instance.imageCache.clear();
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
            titleSpacing: 30.w,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "My School",
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 19),
            ),
            backgroundColor: appColor,
            shape: const CustomAppBarShape(multi: 0.08),
          )),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextFormField(
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            cursorColor: appColor,
            textAlignVertical: TextAlignVertical.center,
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: const Color.fromRGBO(204, 204, 204, 1)),
            textCapitalization: TextCapitalization.none,
            onChanged: (value) {
              setState(() {
                searchString = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              prefixIcon: Icon(Icons.search_sharp,
                  size: 20.h,
                  color: const Color.fromARGB(255, 204, 204, 204)),
              fillColor: const Color.fromRGBO(61, 78, 176, 0.09),
              hintStyle: GoogleFonts.roboto(
                  color: appgreyHomeText,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp),
              hintText: "Find School",
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
        data == null
            ? const CircularProgressIndicator()
            : Expanded(
                child: FutureBuilder<MyTutorModel?>(
                    future: tutorData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: data!.length,
                          itemBuilder: (context, index) {
                            return data[index]
                                    .username
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchString)
                                ? GestureDetector(
                                    onTap: () {
                                      // ignore: void_checks
                                      return CustomDialog.statusDialog(
                                          hrsData,
                                          stdData,
                                          subData,
                                          context,
                                          data[index]);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(10.h),
                                      child: SizedBox(
                                        height: 99.h,
                                        width: double.infinity,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(13.r),
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
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SBW5(),
                                              Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                      padding: EdgeInsets.all(
                                                              10.h),
                                                      child: Container(
                                                          height: 71.h,
                                                          width: 71.h,
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.r),
                                                              ),
                                                              color:
                                                                  Colors.white,
                                                              child: Image.network(
                                                                  data[index]
                                                                      .image!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Image.asset(
                                                                          'assets/Images/ic_avtar.png')))))),
                                              const SBW10(),
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
                                                          data[index].username!,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .roboto(
                                                                  fontSize: 19.sp,
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
                                                              data[index]
                                                                  .subject!,
                                                              subData),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
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
                                                  flex: 3,
                                                  child: Column(children: [
                                                    sselse(data[index].status!),
                                                 const SBH10(),
                                                  GestureDetector(onTap: (){
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ChatPage(
                                                              arguments: ChatPageArguments(
                                                                peerId: data[index].tutorEmail.toString(),
                                                                peerAvatar: data[index].image.toString(),
                                                                peerNickname: data[index].username.toString(),
                                                              ),
                                                            )));
                                                  },child:Align(alignment:Alignment.bottomCenter,child:Column(children: [

                                                              Icon(Icons.chat,size: 14.h,color: appColor,
                                                              ),
                                                   Text("Chat Boat",style: GoogleFonts.roboto(fontSize: 11.sp,color: appColor,fontWeight: FontWeight.w500),)
                                                 ],)))
                                                  ])),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container();
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return data[index]
                                    .username
                                    .toString()
                                    .toLowerCase()
                                    .contains(searchString)
                                ? const SBH1()
                                : Container();
                          },
                        );
                      }
                    }))
      ]),
      bottomNavigationBar:  Container(
        alignment: Alignment.center,
        width: bannerAd!.size.width.toDouble(),
        height: bannerAd!.size.height.toDouble(),
        child: adWidget,)
      );
  }
}

Widget sselse(String status) {
  return Padding(
      padding: EdgeInsets.all(10.h),
      child: Align(
          alignment: Alignment.topRight,
          child: Column(children: [
            if (status != "Pending")
              Text(
                "Paid",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    color: const Color.fromRGBO(12, 175, 89, 1),
                    fontSize: 16.sp),
              )
            else
              Text(
                "Pending",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    color: const Color(0xffefa289),
                    fontSize: 16.sp),
              )
          ])));
}
