import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_cropper/image_cropper.dart';
import '../Helper/helper.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/custom_dialogs.dart';
import 'CustomWidgets/custom_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CustomWidgets/utilss.dart';
import 'bottom_navigation.dart';

class StudentProfile extends StatefulWidget {
  final int type;

  const StudentProfile({Key? key, required this.type}) : super(key: key);

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  final formKey = GlobalKey<FormState>();
  String? _data;
  String email = "",
      username = "",
      stadard = "",
      location = "",
      mobile = "",
      image = "";
  CroppedFile? imageFile;

  @override
  void initState() {
    fetchdata();
    super.initState();
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

  fetchdata() async {
    SharedPred.getEmail().then((value) {
      email = value;
      SharedPred.getUsername().then((value) {
        username = value;
        SharedPred.getLoc().then((value) {
          location = value;
          SharedPred.getImage().then((value) {
            image = value;
            SharedPred.getStd().then((value) {
              stadard = value;
              SharedPred.getMobile().then((value) {
                mobile = value;
                setState(() {
                  _data = "success";
                });
              });
            });
          });
        });
      });
    });
  }
  final ValueNotifier<bool> _counter = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _counterStd = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _counterMob = ValueNotifier<bool>(false);

  TextEditingController usernameCn = TextEditingController();
  TextEditingController stdCn = TextEditingController();
  TextEditingController mobCn = TextEditingController();
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
  Widget build(BuildContext context) {
    usernameCn = TextEditingController(text: username);
    stdCn = TextEditingController(text: stadard);
    mobCn = TextEditingController(text: mobile);

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
              leading: widget.type == 1
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
                "User Profile",
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
            child: _data == null
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Expanded(
                        child: ListView(children : [
                      const SBH20(),
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Select image type",
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          color: appColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    actionsAlignment: MainAxisAlignment.start,
                                    actions: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0),
                                        child: Text(
                                          "Take Image From Gallery",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                              color: appColor,
                                              fontWeight: FontWeight.w200),
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await Utils.pickImageFromGallery()
                                              .then((pickedFile) async {
                                            // Step #2: Check if we actually picked an image. Otherwise -> stop;
                                            if (pickedFile == null) return;

                                            // Step #3: Crop earlier selected image
                                            await Utils.cropSelectedImage(
                                                    pickedFile.path)
                                                .then((croppedFile) {
                                              // Step #4: Check if we actually cropped an image. Otherwise -> stop;
                                              if (croppedFile == null) return;

                                              // Step #5: Display image on screen
                                              setState(() {
                                                imageFile = croppedFile;
                                              });
                                            });
                                          });
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 0),
                                        child: Text(
                                          "Capture Images From Camera",
                                          style: TextStyle(
                                              color: appColor,
                                              fontWeight: FontWeight.w200,fontSize: 14.sp),
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await Utils.pickImageFromCamera()
                                              .then((pickedFile) async {
                                            // Step #2: Check if we actually picked an image. Otherwise -> stop;
                                            if (pickedFile == null) return;

                                            // Step #3: Crop earlier selected image
                                            await Utils.cropSelectedImage(
                                                    pickedFile.path)
                                                .then((croppedFile) {
                                              // Step #4: Check if we actually cropped an image. Otherwise -> stop;
                                              if (croppedFile == null) return;
                                              // Step #5: Display image on screen
                                              setState(() {
                                                imageFile = croppedFile;
                                              });
                                            });
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Stack(children: [
                              Container(
                                  child: imageFile != null
                                      ? CircleAvatar(
                                          radius: 60.r,
                                          child: ClipOval(
                                            child: Image.file(
                                                File(imageFile!.path))
                                          ))
                                      : Container(
                                          child: image == ""
                                              ? CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  backgroundImage: const AssetImage(
                                                      "assets/Images/ic_avtar.png"),
                                                  radius: 60.r,
                                                )
                                              : CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  radius: 60.r,
                                                  child: ClipOval(
                                                    child: Image.network(image,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Image.asset(
                                                                'assets/Images/ic_avtar.png')),
                                                  ),
                                                ),
                                        )),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Padding(
                                      padding: EdgeInsets.only(bottom: 5.h),
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 2,
                                                  color: Colors.black)
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 15.r,
                                            child: const Icon(Icons.edit),
                                          )))),
                            ])),
                      ),
                        const SBH10(),
                        Align(
                            alignment: Alignment.center,
                            child: Text(email,
                                style: GoogleFonts.roboto(
                                    fontSize: 16.sp,
                                    color: appColor,
                                    fontWeight: FontWeight.w500))),
                        const SBH10(),
                        const SBH5(),
                        Padding(
                            padding: EdgeInsets.only(left: 20.w, right: 20.w),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  Column(children: [
                              ValueListenableBuilder<bool>(
                                  builder:
                                  (BuildContext context, bool value, Widget? child) {
                                // This builder will only get called when the _counter
                                // is updated.
                                return
                                    Visibility(visible : _counter.value ,child: Align(alignment: Alignment.topLeft,child : Text("Enter Username"
                                    ,style: TextStyle(fontSize: 11.sp,color: Colors.red,fontWeight: FontWeight.w400),)));
                                   },valueListenable: _counter),
                                    const SBH5(),
                                    TFF(
                                      controler: usernameCn,
                                    color:
                                        const Color.fromRGBO(61, 78, 176, 0.09),
                                    align: TextAlign.center,
                                    hintText: "User Name",
                                    keyboardType: TextInputType.text,
                                    onSaved: (data) {
                                      username = data!.trim();
                                    },
                                  )]),
                                  const SBH10(),
                                  const SBH5(),
                                  ValueListenableBuilder<bool>(
                                      builder:
                                          (BuildContext context, bool value, Widget? child) {
                                        return
                                          Visibility(visible : _counterMob.value ,child: Align(alignment: Alignment.topLeft,
                                              child : Text("Enter Mobile number"
                                            ,style: TextStyle(fontSize: 11.sp,color: Colors.red,fontWeight: FontWeight.w400),)));
                                      },valueListenable: _counterMob),
                                  const SBH5(),
                                  TFF(
                                    controler: mobCn,
                                    color:
                                        const Color.fromRGBO(61, 78, 176, 0.09),
                                    align: TextAlign.center,
                                    hintText: "Mobile Number",
                                    keyboardType: TextInputType.number,
                                    onSaved: (data) {
                                      mobile = data!.trim();
                                    },
                                  ),
                                  const SBH10(),
                                  const SBH5(),
                                  ValueListenableBuilder<bool>(
                                      builder:
                                          (BuildContext context, bool value, Widget? child) {
                                        return
                                          Visibility(visible : _counterStd.value ,child: Align(alignment: Alignment.topLeft,
                                              child : Text("Enter Standard"
                                                ,style: TextStyle(fontSize: 11.sp,color: Colors.red,fontWeight: FontWeight.w400),)));
                                      },valueListenable: _counterStd),
                                  const SBH5(),
                                   TFF(
                                        controler: stdCn,
                                        color: const Color.fromRGBO(
                                            61, 78, 176, 0.09),
                                        align: TextAlign.center,
                                        hintText: "Standard",
                                        onSaved: (data) {
                                          stadard = data!.trim();
                                        },
                                  ),
                                  const SBH10(),
                                  const SBH5(),
                                  StatefulBuilder(
                                    builder: (context, passState) {
                                      return TFF(
                                        initialValue: location,
                                        color: const Color.fromRGBO(
                                            61, 78, 176, 0.09),
                                        align: TextAlign.center,
                                        hintText: "Location",
                                        onSaved: (data) {
                                          location = data!.trim();
                                        },
                                      );
                                    },
                                  ),
                                  const SBH20(),
                                  const SBH10(),
                                  SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: appYellowButton,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.r)),
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold)),
                                        onPressed: () async {
                                          formKey.currentState!.save();
                                          bool isValid =
                                              formKey.currentState!.validate();
                                          if(usernameCn.text == ""){
                                            _counter.value = true;
                                            return;
                                          }
                                          if(mobCn.text == ""){
                                            _counterMob.value = true;
                                            return;
                                          }
                                          if(stdCn.text == ""){
                                            _counterStd.value = true;
                                            return;
                                          }

                                          if (isValid) {
                                            CustomDialog.processDialog(
                                              loadingMessage:
                                                  "Set Profile image",
                                              successMessage:
                                                  "Set Profile image Successfully",
                                            );
                                            if (imageFile != null) {
                                              final resultProfile = await MyServices
                                                      .addStudentTutorProfileImg(
                                                          imageFile!,
                                                          "set_student_profile_image")
                                                  .catchError(
                                                // ignore: body_might_complete_normally_catch_error
                                                (error, stackTrace) {
                                                  myController
                                                      .isProcessDone.value = 0;
                                                  myController
                                                      .processErrorMessage
                                                      .value = error.toString();
                                                },
                                              );
                                              if (resultProfile != null) {
                                                if (resultProfile.status!) {
                                                  callUpdateApi(
                                                      resultProfile.imageurl!);
                                                  myController
                                                      .isProcessDone.value = 2;
                                                  myController
                                                          .processErrorMessage
                                                          .value =
                                                      resultProfile.msg!;
                                                } else {
                                                  myController
                                                      .isProcessDone.value = 0;
                                                  myController
                                                          .processErrorMessage
                                                          .value =
                                                      resultProfile.msg!;
                                                }
                                              }
                                            } else {
                                              callUpdateApi("");
                                            }
                                          }
                                        },
                                        child: const Text(
                                          "Update",
                                        ),
                                      )),
                                  const SBH20(),
                                  const SBH20(),
                                  const SBH20(),
                                ],
                              ),
                            )),
                      ])),
                    ])
                  ),bottomNavigationBar:  SizedBox(
      width: bannerAd!.size.width.toDouble(),
      height: bannerAd!.size.height.toDouble(),
      child: adWidget,
    ));
  }

  Future<void> callUpdateApi(String img) async {
    CustomDialog.processDialog(
      loadingMessage: "Update User Profile",
      successMessage: "Update User Profile Successfully",
    );

    final resultUpd = await MyServices.updateStudentProfile(
            username, location, mobile, stadard)
        .catchError(
      // ignore: body_might_complete_normally_catch_error
      (error, stackTrace) {
        myController.isProcessDone.value = 0;
        myController.processErrorMessage.value = error.toString();
      },
    );
    if (resultUpd != null) {
      if (resultUpd.status!) {
        if (img == "") {
        } else {
          SharedPred.setImage(img);
        }
        SharedPred.setUsername(username);
        SharedPred.setMobile(mobile);
        SharedPred.setStd(stadard);
        SharedPred.setLoc(location);

        Get.offAll(() => const BottomNavigation());
        // myController.isProcessDone.value = 3;
        // myController.processErrorMessage
        //     .value = resultUpd.msg!;
      } else {
        myController.isProcessDone.value = 0;
        myController.processErrorMessage.value = resultUpd.msg!;
      }
    }
  }
}
