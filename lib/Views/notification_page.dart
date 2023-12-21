import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Constants/constants.dart';
import '../Helper/helper.dart';
import '../Models/notification_model.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'CustomWidgets/handle_errors_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  Future<NotificationModel?>? notificationData;
  bool? isAdded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createInterstitialAd();

    fetchData();
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

  void fetchData() {
    notificationData = MyServices.getNotificationList();
  }

  @override
  Widget build(BuildContext context) {
    var colors = [
      const Color.fromRGBO(239, 162, 137, 1),
      const Color.fromRGBO(136, 209, 240, 1),
      const Color.fromRGBO(179, 154, 229, 1),
    ];
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
      if(_interstitialAd !=null){
        _showInterstitialAd();
        return false;
      }else{
        return true;
      }
    },child :Scaffold(
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
            title: Text(
              "Notification",
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
        Expanded(
            child: FutureBuilder<NotificationModel?>(
                future: notificationData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CPI();
                  } else if (snapshot.hasError) {
                    return HandleErrorsPage(
                      errorType: snapshot.error.toString(),
                      tryAgain: () {
                        setState(() {
                          isAdded = false;
                          fetchData();
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
                    if (isAdded == false) {
                      final dataReq = snapshot.data!.reqData;
                      for (int i = 0; i < dataReq!.length; i++) {
                        isAdded = true;
                        data?.add(DataModel(
                            title: "Your ${dataReq[i].sname} Subject Request",
                            type: '',
                            message: "Your ${dataReq[i].sname} Subject's Request Accepted by ${dataReq[i].username}",
                            id: '',
                            userId: ''));
                      }
                    }
                    return ListView.builder(
                        padding: EdgeInsets.only(top: 0, left: 8.w, right: 8.w),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsets.all(10.h),
                              child: Container(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    color: colors[index % 3],
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.06),
                                        offset: Offset(
                                          0.0,
                                          0.0,
                                        ),
                                        blurRadius: 10.0,
                                        spreadRadius: 4.0,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.r),
                                            topRight: Radius.circular(8.r)),
                                        color: Colors.white,
                                      ),
                                      child: ExpansionPanelList(
                                        animationDuration:
                                            const Duration(milliseconds: 1000),
                                        elevation: 0,
                                        children: [
                                          ExpansionPanel(
                                            canTapOnHeader: true,
                                            body: Padding(
                                              padding:EdgeInsets.only(
                                                  bottom: 5.h, left: 5.w, right: 5.w),
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    data[index].message,
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16.sp,
                                                        color: const Color
                                                                .fromRGBO(
                                                            152, 152, 152, 1)),
                                                  )),
                                            ),
                                            headerBuilder:
                                                (BuildContext context,
                                                    bool isExpanded) {
                                              return Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    data[index].title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign:
                                                        TextAlign.center,
                                                    style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 19.sp,
                                                        color: const Color
                                                                .fromRGBO(
                                                            98, 98, 98, 1)),
                                                  ));
                                            },
                                            isExpanded: data[index].expanded,
                                          )
                                        ],
                                        expansionCallback:
                                            (int item, bool status) {
                                          setState(() {
                                            data[index].expanded =
                                                !data[index].expanded;
                                          });
                                        },
                                      ))));
                        });
                  }
                }))
      ]),
    ));
  }
}
