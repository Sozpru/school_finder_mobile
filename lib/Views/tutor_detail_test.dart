
// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:convert';

import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Models/hours_avail_model.dart';
import 'package:e_tutor/Models/tutor_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Constants/sharedpref.dart';
import '../Helper/helper.dart';
import '../Models/standard.dart';
import '../Models/subject_model.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/custom_dialogs.dart';
import 'CustomWidgets/handle_errors_page.dart';
import 'CustomWidgets/show_snackbar.dart';
import 'CustomWidgets/triangle.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bottom_navigation.dart';

class TutorDetail extends StatefulWidget {

  final String emailAdd;
  final List<StandardDataModel?>? stdData;
  final List<SubjectDataModel?>? subData;
  const TutorDetail(this.emailAdd, this.stdData,
      this.subData,{Key? key }) : super(key: key);

  @override
  State<TutorDetail> createState() => _TutorDetailState();
}

class _TutorDetailState extends State<TutorDetail>{

  var colors = [
    const Color.fromRGBO(239, 162, 137, 1),
    const Color.fromRGBO(136, 209, 240, 1),
    const Color.fromRGBO(179, 154, 229, 1),
    const Color.fromRGBO(52, 94, 168, 1),
  ];

  var title = [
    "Year of Exp.",
    "Teaching to",
    "Distance",
    "University",
  ];
  // ignore: prefer_typing_uninitialized_variables
  var title2;

  String? data;
  String? dataBottom;
  Future<TutorDetailModel?>? tutorDetail;
  final ValueNotifier<String> counterRat = ValueNotifier<String>("");
  InterstitialAd? _interstitialAd;

  @override
  void initState(){
    super.initState();
    _createInterstitialAd();
    getHours();
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
    const adUnitId =  'ca-app-pub-3940256099942544/1033173712';

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

  Future<TutorDetailModel?> fetchTutorDetail() async {
    var aa = widget.emailAdd;
    box.write("tutor_detail_email", aa);
    tutorDetail = MyServices.getTutorDetail(aa);
    return tutorDetail;
  }


  List<HoursAvailData?>? hoursAvail;
  List<SubjectDataModel> sub = [];
  late Data dataModel;
  List<String> fees = [];
  List<SubjectDataModel>? subjectData = [];

  getHours() async {
    SharedPred.getHoursModel().then((value) {
      hoursAvail = (json.decode(value!) as List)
          .map((data) => HoursAvailData.fromJson(data))
          .toList();
      SharedPred.getSubjectModel().then((value) {
        subjectData = (json.decode(value!) as List)
            .map((data) => SubjectDataModel.fromJson(data))
            .toList();
        setState(() {
          data = "success";
        });
      });
    });
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
    },child : DefaultTabController(
        length: 3,
        child :Scaffold(appBar: PreferredSize(
            preferredSize: Size.fromHeight((size.height / 10)),
                child : AppBar(
                  systemOverlayStyle: const SystemUiOverlayStyle(
                    systemNavigationBarColor: appColor, // Navigation bar
                    statusBarColor: appColor, // Status bar
                  ),
                  titleSpacing: 30.h,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,size: 25.h,),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text("Detail of School",style: GoogleFonts.roboto(color: Colors.white,fontWeight: FontWeight.w500,
                      fontSize: 19.sp),),
                  backgroundColor: appColor,
                  shape: CustomAppBarShape(multi: 0.08.h),)),
        body :  data == null
            ? const Center(
            child: CircularProgressIndicator(
              color: appColor,
            ))
            : FutureBuilder<TutorDetailModel?>(
    future: fetchTutorDetail(),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const CPI();
    } else if (snapshot.hasError) {
    return HandleErrorsPage(
    errorType: snapshot.error.toString(),
    tryAgain: () {
    setState(() {
    fetchTutorDetail();
    });
    },
    );
    } else if (!snapshot.data!.status) {
    return HandleErrorsPage(
    errorType: snapshot.data!.msg,
    );
    }else if(snapshot.data!.status & (snapshot.data!.msg == "Data Not Found")){
      return HandleErrorsPage(
        errorType: snapshot.data!.msg,
      );
    } else {
      dataModel = snapshot.data!.data[0];
      sub = setArrayfromSeparated(
          dataModel.subject!, subjectData);
      fees = getMonthlyFees(dataModel.monthlyFees!);
      final std = getSringfromSTDArray(
          dataModel.standard!, widget.stdData);
      box.write("tution_type", dataModel.tuitionType);
      counterRat.value = snapshot.data!.data[0].rate!;
      title2 = [
        snapshot.data!.data[0].yearOfExperience!,
        "${snapshot.data!.data[0].standard!.replaceAll(",", "-")} Std",
        snapshot.data!.data[0].distance!,
        snapshot.data!.data[0].university!,
      ];
    return
    Container(color: Colors.white,child :  Column(
              children :[
                const SBH20(),
                const SBH20(),
                Row(children : [
                  const SBW10(),
                  CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 37.r,
                      child: ClipOval(
                        child: Image.network(
                            dataModel.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error,
                                stackTrace) =>
                                Image.asset(
                                    'assets/Images/ic_avtar.png')
                        ),
                      )
                  ),
                  const SBW10(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data!.data[0].username!,style: GoogleFonts.roboto(
                          fontSize: 19.sp,color: const Color.fromRGBO(98, 98, 98, 1,),fontWeight: FontWeight.w500)),
                      const SBH5(),
                      Text(std,style: GoogleFonts.roboto(fontWeight: FontWeight.w300,
                          fontSize: 17.sp,color: const Color.fromRGBO(116, 115, 144, 1))),
                      const SBH5(),
                      Text(snapshot.data!.data[0].subjectName!,style: GoogleFonts.roboto(fontWeight: FontWeight.w300,
                          fontSize: 17.sp,color: const Color.fromRGBO(152, 152, 152, 1))),
                    ],),
                  Expanded(child:
                  Padding(padding: EdgeInsets.only(right: 20.w),
                  child : GestureDetector(onTap:(){
                    SharedPred.getTutorRating(snapshot.data!.data[0].email!).then((value) {
                    CustomDialog.ratingDilog(context,snapshot.data!.data[0].email!,value.toString()).then((value){
                      if(value != null) {
                        counterRat.value = value.toString();
                      }
                    });
                    });
                  },child : ValueListenableBuilder<String>(
                                      builder: (BuildContext context,
                                          String value, Widget? child) {
                      return Column(children: [
                    Align(alignment: Alignment.centerRight,child : Column(children: [
                      Icon(Icons.star,color: const Color.fromRGBO(247, 186, 52, 1),
                      size: 24.19.h,),
                      const SBW5(),
                      Text("${counterRat.value} / 5",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500, fontSize: 17.sp,color: const Color.fromRGBO(98, 98, 98, 1)))
                    ],))
                  ]);},valueListenable: counterRat)))),
                ],
                ),
                const SBH10(),
                const SBH10(),
                Container(color: Colors.white,child :
                SizedBox(height : 100.h,child:
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index){
                    return GestureDetector(
                        child: SizedBox(
                            height: 100.h,
                            width: 150.w,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.r)
                                ),
                                margin: EdgeInsets.only(left: 10.w,right: 10.w),
                                elevation: 0,
                                color: colors[index],
                                child : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children : [
                                      Text(title[index],style: GoogleFonts.roboto(fontWeight: FontWeight.w400,
                                          fontSize: 16.sp,color: Colors.white
                                      )),
                                      const SBH5(),
                                      Text(title2[index],textAlign: TextAlign.start,style: GoogleFonts.roboto(
                                          fontSize: 24.sp,color: Colors.white,fontWeight: FontWeight.w700
                                      ))
                                    ]
                                ))
                        ));
                  },
                )
                )),
                const SBH10(),
                Column(
                          children: [
                            Container(
                              height: 45.h,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(249, 249, 255, 1),
                              ),
                              child: TabBar(
                                padding: EdgeInsets.zero,
                                tabs: [
                                  Row (children: [const Icon(Icons.price_check_rounded,),  Text("Pricing",style: GoogleFonts.roboto(fontSize: 13.sp,fontWeight: FontWeight.w400),)]),
                                  Row (children: [const Icon(Icons.person_add_alt_sharp,), Text("Availability",style: GoogleFonts.roboto(fontSize: 13.sp,fontWeight: FontWeight.w400),)]),
                                  Row (children: [const Icon(Icons.contacts_outlined,),  Text(" Contact",style: GoogleFonts.roboto(fontSize: 13.sp,fontWeight: FontWeight.w400),)]),
                                ],
                                unselectedLabelColor: const Color.fromRGBO(152, 152, 152, 1),
                                labelColor: appColor,
                                indicatorColor: const Color.fromRGBO(246, 189, 96, 1),
                                indicatorWeight: 3.h,
                                indicatorPadding: EdgeInsets.only(left: 40.w,right: 40.w),
                              ),
                            ),
                          ],
                        ),
                Expanded(
                     child: TabBarView(
                       children:<Widget> [
                         Pricing(sub,fees),
                         Availability(dataModel.aHours!,dataModel.mHours!,int.parse(snapshot.data!.data[0].tuitionType!),hoursAvail),
                         Contact(snapshot.data!.data[0].email!,snapshot.data!.data[0].mobileNo!),
                       ],
                     ),
                )
              ]
    )
    );}}
    )
    )));
  }
}

class Availability extends StatefulWidget {
  final int tutionType;
  final String aHours, mHours;
  final List<HoursAvailData?>? hoursAvail;

  const Availability(this.aHours, this.mHours,
      this.tutionType, this.hoursAvail,
      {Key? key})
      : super(key: key);

  @override
  State<Availability> createState() => _AvailabilityPageState();
}


class _AvailabilityPageState extends State<Availability> with AutomaticKeepAliveClientMixin{
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);
    _counter.value = widget.tutionType;

    return Padding(
      padding: EdgeInsets.only(top: 5.h,right: 10.w,left: 10.w),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          Align(
              alignment: Alignment.center,
              child: ClipPath(
                clipper: Triangle(),
                child: Container(
                  color: const Color.fromRGBO(238, 239, 248, 1),
                  width: 20.w,
                  height: 10.h,
                ),
              )),
          Container(
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 15.h),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(238, 239, 248, 1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  const SBH5(),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text('Tution type',
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              fontSize: 17.sp,
                              color: const Color.fromRGBO(98, 98, 98, 1)))),
                  const SBH5(),
                  Row(children: [
                    ValueListenableBuilder<int>(
                        builder:
                            (BuildContext context, int value, Widget? child) {
                          return Row(children: [Radio(
                                    value: 1,
                                    groupValue: _counter.value,
                                    activeColor: appColor,
                                    onChanged: (val) {
                                      if (widget.tutionType == 3) {
                                        _counter.value = val!;
                                        box.write(
                                            "tution_type", _counter.value);
                                      }
                                    },
                                  ),Transform.translate(offset: const Offset(-10,0),child :Text("Online",style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: const Color.fromRGBO(
                                  98, 98, 98, 1))))]);
                        },
                        valueListenable: _counter),
                    ValueListenableBuilder<int>(
                        builder:
                            (BuildContext context, int value, Widget? child) {
                          return  Row(children: [
                            Radio(
                                    value: 2,
                                    groupValue: _counter.value,
                                    activeColor: appColor,
                                    onChanged: (val) {
                                      if (widget.tutionType == 3) {
                                        _counter.value = val!;
                                        box.write(
                                            "tution_type", _counter.value);
                                      }
                                    }),
                            Transform.translate(offset: const Offset(-10,0),child : Text("Offline",style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                color: const Color.fromRGBO(
                                    98, 98, 98, 1))))
                          ]
                          );
                        },
                        valueListenable: _counter),
                    ValueListenableBuilder<int>(
                        builder:
                            (BuildContext context, int value, Widget? child) {
                          // This builder will only get called when the _counter
                          // is updated.
                          return  Row(children: [Radio(
                                    value: 3,
                                    groupValue: _counter.value,
                                    activeColor: appColor,
                                    onChanged: (val) {
                                      if (widget.tutionType == 3) {
                                        _counter.value = val!;
                                        box.write(
                                            "tution_type", _counter.value);
                                      }
                                    },
                                  ),Transform.translate(offset: const Offset(-10,0),child :Text("Both",style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w400,
                              fontSize: 14.sp,
                              color: const Color.fromRGBO(
                              98, 98, 98, 1))))
                          ]);
                        },
                        valueListenable: _counter),
                  ]),
                  AvailabilityHours(
                      widget.aHours, widget.mHours, widget.hoursAvail),
                ],
              )),
          const SBH20(),
          const SBH10(),
          Padding(padding: EdgeInsets.all(10.h), child:
          SizedBox(
              width: double.infinity,
              child : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0.0, backgroundColor: appYellowButton,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)
                    ),
                    textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 18.sp,)),
                onPressed: () async {
                  callSendReq(context);
                },
                child: const Text(
                  "Send Request",
                ),
              )))
        ],
      ),
    );
  }

  List amhrsList = [];

  void horseSelectAM(bool selected, String hrId) {
    if (selected == true) {
      setState(() {
        amhrsList.add(hrId);
      });
    } else {
      setState(() {
        amhrsList.remove(hrId);
      });
    }
    box.write("sendDataAMHours", amhrsList.join(","));
  }

  List pmhrsList = [];

  void horseSelectPM(bool selected, String hrId) {
    if (selected == true) {
      setState(() {
        pmhrsList.add(hrId);
      });
    } else {
      setState(() {
        pmhrsList.remove(hrId);
      });
    }
    box.write("sendDataPMHours", pmhrsList.join(","));
  }
}

class AvailabilityHours extends StatefulWidget {
  final String aHours, mHours;
  final List<HoursAvailData?>? hoursAvail;

  const AvailabilityHours(this.aHours, this.mHours,
      this.hoursAvail,
      {Key? key})
      : super(key: key);

  @override
  State<AvailabilityHours> createState() => _AvailabilityHoursPageState();
}

class _AvailabilityHoursPageState extends State<AvailabilityHours> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<HoursAvailData> hoursAvailAM =
    getHoursAvailArray(widget.hoursAvail, "am", widget.mHours);
    final List<HoursAvailData> hoursAvailPM =
    getHoursAvailArray(widget.hoursAvail, "pm", widget.aHours);

    return Column(
      children: [
        const SBH5(),
        if ((hoursAvailPM.isNotEmpty) & (hoursAvailAM.isNotEmpty))
          DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 1.h,
            dashLength: 4.w,
            dashColor: appYellowButton,
          ),
        const SBH10(),
        const SBH10(),
        if ((hoursAvailPM.isNotEmpty) & (hoursAvailAM.isNotEmpty))
          Align(
              alignment: Alignment.topLeft,
              child: Text('Hours of Availability',
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      fontSize: 17.sp,
                      color: const Color.fromRGBO(98, 98, 98, 1)))),
        const SBH10(),
        if (hoursAvailAM.isNotEmpty)
          Column(children: [
            Align(
                alignment: Alignment.topLeft,
                child: Text('Morning Hours',
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w300,
                        fontSize: 14.sp,
                        color: const Color.fromRGBO(152, 152, 152, 1)))),
            const SBH5(),
            SizedBox(
                height: 37.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: hoursAvailAM.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            horseSelectAM(!hoursAvailAM[index].isSelected,
                                hoursAvailAM[index].id!);
                            hoursAvailAM[index].isSelected =
                            !hoursAvailAM[index].isSelected;
                          });
                        },
                        child: SizedBox(
                            height: 37.h,
                            width: 91.w,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 0.7.w,
                                    color: const Color.fromRGBO(52, 94, 168, 0.3)),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              margin: EdgeInsets.only(left: 10.w, right: 10.w),
                              elevation: 0,
                              color: hoursAvailAM[index].isSelected
                                  ? appColor
                                  : Colors.white,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      hoursAvailAM[index]
                                          .hours!
                                          .replaceAll(":00", ""),
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.sp,
                                          color: hoursAvailAM[index].isSelected
                                              ? Colors.white
                                              : const Color.fromARGB(
                                              98, 98, 98, 1)))),
                            )));
                  },
                )),
          ]),
        if (hoursAvailAM.isNotEmpty & hoursAvailPM.isNotEmpty)
          Column(children: [
            const SBH10(),
            const SBH5(),
            DottedLine(
              direction: Axis.horizontal,
              lineLength: double.infinity,
              lineThickness: 1.h,
              dashLength: 4.w,
              dashColor: Colors.white,
            ),
            const SBH10(),
          ]),
        if (hoursAvailPM.isNotEmpty)
          Column(children: [
            Align(
                alignment: Alignment.topLeft,
                child: Text('Afternoon Hours',
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w300,
                        fontSize: 14.sp,
                        color: const Color.fromRGBO(152, 152, 152, 1)))),
            const SBH5(),
            SizedBox(
                height: 37.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: hoursAvailPM.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          setState(() {
                            horseSelectPM(!hoursAvailPM[index].isSelected,
                                hoursAvailPM[index].id!);
                            hoursAvailPM[index].isSelected =
                            !hoursAvailPM[index].isSelected;
                          });
                        },
                        child: SizedBox(
                            height: 37.h,
                            width: 91.w,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 0.7.w,
                                      color: const Color.fromRGBO(52, 94, 168, 0.3)),
                                  borderRadius: BorderRadius.circular(4.r)),
                              margin: EdgeInsets.only(left: 10.w, right: 10.w),
                              elevation: 0,
                              color: hoursAvailPM[index].isSelected
                                  ? appColor
                                  : Colors.white,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                      hoursAvailPM[index]
                                          .hours!
                                          .replaceAll(":00", ""),
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.sp,
                                          color: hoursAvailPM[index].isSelected
                                              ? Colors.white
                                              : const Color.fromARGB(
                                              98, 98, 98, 1)))),
                            )));
                  },
                )),
          ])
      ],
    );
  }

  List amhrsList = [];

  void horseSelectAM(bool selected, String hrId) {
    if (selected == true) {
      setState(() {
        amhrsList.add(hrId);
      });
    } else {
      setState(() {
        amhrsList.remove(hrId);
      });
    }
    box.write("sendDataAMHours", amhrsList.join(","));
  }

  List pmhrsList = [];

  void horseSelectPM(bool selected, String hrId) {
    if (selected == true) {
      setState(() {
        pmhrsList.add(hrId);
      });
    } else {
      setState(() {
        pmhrsList.remove(hrId);
      });
    }
    box.write("sendDataPMHours", pmhrsList.join(","));
  }
}

class Pricing extends StatefulWidget {
  final List<SubjectDataModel> sub;
  final List<String> fees;

  const Pricing(this.sub, this.fees,
      {Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PricingPageState createState() => _PricingPageState();
}

class _PricingPageState extends State<Pricing>  with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: EdgeInsets.only(top: 5.h,left: 10.w,right: 10.w),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 35.w),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: ClipPath(
                    clipper: Triangle(),
                    child: Container(
                      color: const Color.fromRGBO(238, 239, 248, 1),
                      width: 20.w,
                      height: 10.h,
                    ),
                  ))),
          Container(
              padding: EdgeInsets.fromLTRB(15.w, 10.h, 20.w, 5.h),
              //extra 10 for top padding because triangle's height = 10
              decoration: BoxDecoration(
                color: const Color.fromRGBO(238, 239, 248, 1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text('Monthly Fees',
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              fontSize: 17.sp,
                              color: const Color.fromRGBO(98, 98, 98, 1)))),
                  const SBH10(),
                  Padding(
                      padding: EdgeInsets.only(left: 10.w, right: 10.w),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: widget.sub.length,
                        itemBuilder: (context, index) {
                          bool isFees = false;
                          if(widget.fees.isEmpty){
                            isFees = false;
                          }else{
                            isFees = true;
                          }

                          return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: appColor,
                              tileColor: appColor,
                              selectedTileColor: appColor,
                              checkColor: Colors.white,
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              //font change
                              secondary: Text(isFees? widget.fees[index] : "",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17.sp,
                                    color: const Color.fromRGBO(98, 98, 98, 1),
                                  )),
                              // subtitle: Text(price[index]),
                              title: Transform.translate(
                                  offset: Offset(-15.w, 0),
                                  child: Text(widget.sub[index].subjectName!,
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                        color:
                                        const Color.fromRGBO(98, 98, 98, 1),
                                      ))),
                              value: _selecteCategorys
                                  .contains(widget.sub[index].id),
                              onChanged: (bool? newValue) {
                                _onCategorySelected(newValue!,
                                    widget.sub[index].id, widget.fees[index]);
                              });
                        },
                      )),
                  DottedLine(
                    direction: Axis.horizontal,
                    lineLength: double.infinity,
                    lineThickness: 1.h,
                    dashLength: 4.w,
                    dashColor: Colors.white,
                  ),
                  const SBH10(),
                  Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque varius odio nibh ultrices tincidunt dapibus. Diam vulputate tincidunt lacus, volutpat sit nibh.",
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: const Color.fromRGBO(98, 98, 98, 1)),
                  ),
                  const SBH10(),
                ],
              )),
          const SBH20(),
          const SBH10(),
          Padding(padding: EdgeInsets.all(10.h), child:
          SizedBox(
              width: double.infinity,
              child : ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0.0, backgroundColor: appYellowButton,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)
                    ),
                    textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 18.sp,)),
                onPressed: () async {
                  callSendReq(context);
                },
                child: const Text(
                  "Send Request",
                ),
              )))
        ],
      ),
    );
  }

  final List _selecteCategorys = [];
  List feesList = [];

  void _onCategorySelected(bool selected, categoryId, String fees) {
    if (selected == true) {
      setState(() {
        feesList.add(fees);
        _selecteCategorys.add(categoryId);
      });
    } else {
      setState(() {
        feesList.remove(fees);
        _selecteCategorys.remove(categoryId);
      });
    }
    box.write("sendDataFees", feesList.join(","));
    box.write("sendDatasubj", _selecteCategorys.join(","));
  }

}

Future<void> callSendReq(BuildContext context) async {

  BuildContext dialogContext;
  var fees = box.read("sendDataFees");
  var sub = box.read("sendDatasubj");
  var amHrs = box.read("sendDataAMHours") ?? "";
  var pmHrs = box.read("sendDataPMHours") ?? "";
  var tEmail = box.read("tutor_detail_email");
  var tutionType = box.read("tution_type");

  dialogContext = context;
  if (fees == null || fees == "") {
    showSnackBar(dialogContext, 'Please select subject ');
  } else {
    CustomDialog.processDialog(
      loadingMessage: "Request Sending",
      successMessage: "Request Send Successfully",
    );

    final result1 = await MyServices.sendRequest(
        tEmail, sub, fees, amHrs, pmHrs, tutionType.toString())
        .catchError(
          (error, stackTrace) {
        myController.isProcessDone.value = 0;
        myController.processErrorMessage.value = error.toString();
      },
    );
    if (result1 != null) {
      if (result1.status!) {
        myController.isProcessDone.value = 2;
        if(dialogContext.mounted) {
          CustomDialog.requestSendDilog(dialogContext);
          Get.offAll(() => const BottomNavigation());
        }else{
          return;
        }
      } else {
        myController.isProcessDone.value = 0;
        myController.processErrorMessage.value = result1.msg!;
      }
    }
  }
}


class Contact extends StatefulWidget {

  // ignore: prefer_typing_uninitialized_variables
  final email,mobile;
  const Contact(this.email,this.mobile, {Key? key}) : super(key: key);

  @override
  State<Contact> createState() => _ContactPageState();
}

  class _ContactPageState extends State<Contact> {

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(top : 10.h,left: 10.w,right: 10.w),
        child : ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: <Widget>[ Column(mainAxisAlignment : MainAxisAlignment.start,
            children :[
          Padding(padding: EdgeInsets.only(right: 35.w),child : Align(alignment: Alignment.topRight,child:
            ClipPath(
              clipper: Triangle(),
              child: Container(
                color: const Color.fromRGBO(238, 239, 248, 1),
                width: 20.w,
                height: 10.h,
              ),
            ))),
            Container(
    padding: EdgeInsets.fromLTRB(15.w, 10.h, 20.w, 20.h),   //extra 10 for top padding because triangle's height = 10
    decoration: BoxDecoration(
    color: const Color.fromRGBO(238, 239, 248, 1),
    borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(children: [
      Align(alignment: Alignment.topLeft,child : Text('Contact Information',
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.w500, fontSize: 17.sp,color: const Color(0xff626262)))),
      const SBH10(),
      const SBH10(),
      Row(children: [
        Icon(Icons.email_rounded,color: const Color.fromRGBO(204, 204, 204, 1),size: 23.h),
        const SBW10(),
        Text(widget.email,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w400,
            fontSize: 17.sp,color: const Color.fromRGBO(98, 98, 98, 1))),
      ],),
      const SBH10(),
      if(widget.mobile.toString() != "")
      Row(children: [
        Icon(Icons.call_rounded,color: const Color.fromRGBO(204, 204, 204, 1),size: 23.h,),
        const SBW10(),
        Text(widget.mobile,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w400,
            fontSize: 17.sp,color: const Color.fromRGBO(98, 98, 98, 1))),
      ],)
    ]
    ),
    ),
              const SBH20(),
              const SBH20(),
              const SBH10(),
              Padding(padding: EdgeInsets.all(10.h), child:
              SizedBox(
                  width: double.infinity,
                  child : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0.0, backgroundColor: appYellowButton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)
                        ),
                        textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 18.sp,)),
                    onPressed: () async {
                      callSendReq(context);
                    },
                    child: const Text(
                      "Send Request",
                    ),
                  )))
            ]
    )]));
  }
}
