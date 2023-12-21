import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Constants/constants.dart';
import '../Helper/helper.dart';

import 'dart:io' show Platform;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Models/about_privacy_model.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'CustomWidgets/handle_errors_page.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key, required String this.s, required int this.type})
      : super(key: key);

  final String? s;
  final int? type;

  @override
  State<AboutUs> createState() => AboutUsPage();
}

Future<AboutPrivacyModel?>? fetchdata() async {
  return MyServices.getAboutAndPrivacy();
}


class AboutUsPage extends State<AboutUs> {
  InterstitialAd? _interstitialAd;


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
  void initState() {
    // TODO: implement initState
    super.initState();
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
              systemOverlayStyle:  const SystemUiOverlayStyle(
                systemNavigationBarColor: appColor, // Navigation bar
                statusBarColor: appColor, // Status bar
              ),
              titleSpacing: 30.w,
              leading: IconButton(
                icon:  Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 25.w,
                ),
                onPressed: () => {
                  if(_interstitialAd !=null){
                  _showInterstitialAd()
              }else{
                    Navigator.pop(context)
                  }
            },
              ),
              title: Text(
                widget.s!,
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 19.sp),
              ),
              backgroundColor: appColor,
              shape: CustomAppBarShape(multi: 0.08.h),
            )),
        body: AnnotatedRegion(
            value: const SystemUiOverlayStyle(statusBarColor: appColor),
            child: Column(children: [
              const SBH20(),
              const SBH20(),
              Expanded(
                  child: FutureBuilder<AboutPrivacyModel?>(
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
                          return ListView(padding: EdgeInsets.zero, children: [
                            Padding(
                                padding: EdgeInsets.only(left: 20.w, right: 20.w),
                                child: Html(
                                  data: widget.type == 0
                                      ? data![0].about.toString()
                                      : data![0].privacyPolicy.toString(),
                                ))
                          ]);
                        }
                      })),
              const SBH20(),
              const SBH20(),
            ])),bottomNavigationBar: SizedBox(
      width: bannerAd!.size.width.toDouble(),
      height: bannerAd!.size.height.toDouble(),
      child: adWidget,
    )));
  }
}
