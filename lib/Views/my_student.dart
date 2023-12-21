import 'dart:convert';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Models/hours_avail_model.dart';
import 'package:e_tutor/Views/CustomWidgets/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Chat/chat_page.dart';
import '../Constants/constants.dart';
import '../Helper/helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Models/my_student_model.dart';
import '../Models/subject_model.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/handle_errors_page.dart';
import 'dart:io';

class MyStudentList extends StatefulWidget {
  const MyStudentList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyStudentListState createState() => _MyStudentListState();
}

class _MyStudentListState extends State<MyStudentList> {
  Future<Student?>? studentData;
  String? data;
  List<SubjectDataModel> subData = [];
  List<HoursAvailData> hrsData = [];
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    fetchSub();
    _createInterstitialAd();
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

  void _showInterstitialAd() {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        Navigator.pop(context);
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createInterstitialAd() {
    const adUnitId =  intAdvId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          // _showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
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
    studentData = MyServices.getMyStudentList("my_student");
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
    return WillPopScope(
        onWillPop: () async {
      if(_interstitialAd !=null){
        _showInterstitialAd();
        return false;
      }else{
        return true;
      }
    },child : Scaffold(
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
                onPressed: () => {
                  if(_interstitialAd != null){
                    _showInterstitialAd()
                  } else {
                      Navigator.pop(context)
                    }
                }
              ),
              title: Text(
                "My Student",
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 19.sp),
              ),
              backgroundColor: appColor,
              shape: CustomAppBarShape(multi: 0.08.h),
            )),
        body: Column(children: [
          const SBH10(),
          data == null
              ? const CircularProgressIndicator()
              : Container(padding : EdgeInsets.only(bottom: 50.h),
              child : Expanded(child: FutureBuilder<Student?>(
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
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    CustomDialog.myStudentDialog(
                                        subData, hrsData, data[index], context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(10.h),
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
                                            color: Colors.white),
                                        height: 85.h,
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
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
                                              Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                  flex: 2,
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                              right: 5.w),
                                                      child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                "Fees",
                                                                style: GoogleFonts.roboto(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    fontSize:
                                                                        14.sp,
                                                                    color: const Color
                                                                            .fromRGBO(
                                                                        204,
                                                                        204,
                                                                        204,
                                                                        1)),
                                                              ),
                                                              if (data[index]
                                                                      .status ==
                                                                  "Paid")
                                                                Text(
                                                                  "Received",
                                                                  style: GoogleFonts.roboto(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          16.sp,
                                                                      color: const Color
                                                                              .fromRGBO(
                                                                          12,
                                                                          175,
                                                                          89,
                                                                          1)),
                                                                )
                                                              else
                                                                Text(
                                                                  "Pending",
                                                                  style: GoogleFonts.roboto(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          16.sp,
                                                                      color: const Color
                                                                              .fromRGBO(
                                                                          239,
                                                                          162,
                                                                          137,
                                                                          1)),
                                                                ),
                                                              const SBH10(),
                                                              Align(alignment:Alignment.bottomCenter,child:Column(children:
                                                              [
                                                                GestureDetector(onTap: (){
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ChatPage(
                                                                            arguments: ChatPageArguments(
                                                                              peerId: data[index].studentEmail.toString(),
                                                                              peerAvatar: data[index].image.toString(),
                                                                              peerNickname: data[index].username.toString(),
                                                                            ),
                                                                          )));
                                                                },child:
                                                                Icon(Icons.chat,size: 14.h,color: appColor,
                                                                ),
                                                                ),
                                                                Text("Chat Boat",style: GoogleFonts.roboto(fontSize: 11.sp,color: appColor,fontWeight: FontWeight.w500),)
                                                              ],))
                                                            ],
                                                          )))),
                                             ])),
                                  ));
                            },
                          );
                        }
                      }))),
        ]),
    bottomNavigationBar: BottomAppBar(child: Container(
      alignment: Alignment.center,
      width: bannerAd!.size.width.toDouble(),
      height: bannerAd!.size.height.toDouble(),
      child: adWidget,
    )),));
  }
}
