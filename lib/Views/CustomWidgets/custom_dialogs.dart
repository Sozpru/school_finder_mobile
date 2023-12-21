import 'package:e_tutor/Models/hours_avail_model.dart';
import 'package:e_tutor/Models/standard.dart';
import 'package:e_tutor/Models/subject_model.dart';
import 'package:e_tutor/Services/my_services.dart';
import 'package:e_tutor/Views/CustomWidgets/show_snackbar.dart';
import 'package:e_tutor/Views/CustomWidgets/triangle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Constants/constants.dart';
import '../../Constants/sharedpref.dart';
import '../../Helper/helper.dart';
import '../../Models/my_student_model.dart';
import '../../Models/my_tutor_model.dart';
import '../my_tutor.dart';
import '../payment.dart';

class CustomDialog {
  static attentionDialog({required String middleText}) {
    Get.defaultDialog(
      title: "Attention !",
      middleText: middleText,
      titleStyle: Get.textTheme.displaySmall?.copyWith(color: Colors.red),
      middleTextStyle: Get.textTheme.headlineMedium,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: Text(
          "Got it",
          style: Get.textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  static statusDialog(List<HoursAvailData> hrsData,
      List<StandardDataModel> stdData, List<SubjectDataModel> subData,
      BuildContext context, MyTutorDataModel dataModel) {
    var ss = getHourssepComma(hrsData, dataModel.aHours!, dataModel.mHours!);
    bool ttt = false;
    ss == "" ? ttt = true : ttt = false;
    var tutType = "";
    if (dataModel.tuitionType == "1") {
      tutType = "Online";
    } else if (dataModel.tuitionType == "2") {
      tutType = "Offline";
    } else if (dataModel.tuitionType == "3") {
      tutType = "Both";
    }

    final split = dataModel.fees!.split(',');
    final Map<int, String> values = {
      for (int i = 0; i < split.length; i++)
        i: split[i]
    };
    int fees = 0;
    for (int k = 0; k < values.length; k++) {
      fees += int.parse(values[k]!);
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              insetPadding: EdgeInsets.all(12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: ListView(
                  children: [Column(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(right: 4.w, top: 4.h),
                            child: Align(alignment: Alignment.topRight, child:
                            IconButton(icon:Icon(
                                Icons.clear, size: 27.h, color: const Color(
                                0xffcccccc)),
                              onPressed: () {
                                Navigator.pop(context);
                              },))),
                        Row(children: [
                          const SBW10(),
                          Align(alignment: Alignment.topLeft, child:
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
                          )),
                          const SBW10(),
                          const SBW5(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(dataModel.username!, style: GoogleFonts
                                  .roboto(
                                  fontSize: 19.sp,
                                  color: const Color.fromRGBO(98, 98, 98, 1,),
                                  fontWeight: FontWeight.w500)),
                              const SBH5(),
                              Text(dataModel.mobileNo!, style: GoogleFonts
                                  .roboto(fontWeight: FontWeight.w400,
                                  fontSize: 17.sp,
                                  color: const Color.fromRGBO(
                                      116, 115, 144, 1))),
                            ],),
                        ],),
                        const SBH5(),
                        if(dataModel.status == "Pending")
                          GestureDetector(onTap: () {
                            int sumOfFees = fees;
                            if (sumOfFees == 0) {
                              showSnackBar(context, "Please select fees");
                            } else {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                            PaymentPage(pay: sumOfFees.toString(),
                                                email: '${dataModel.tutorEmail}',name : '${dataModel.username}')
                                    ));
                              // PaymentPage(email: '${box.read("tutor_detail_email")}')
                            }
                          },
                              child:
                              SizedBox(
                                width: 145.w,
                                height: 40.h,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            8.r)),
                                    color: appColor,
                                    elevation: 0,
                                    child: Align(alignment: Alignment.center,
                                        child: Text("Pay Fees $fees",
                                            style: GoogleFonts.roboto(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white)
                                        ))),
                              )),
                        const SBH10(),
                        Padding(padding: EdgeInsets.all(10.h), child:
                        SizedBox(
                            width: double.infinity,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),),
                                elevation: 0,
                                color: const Color.fromRGBO(248, 248, 255, 1),
                                child: Padding(padding: EdgeInsets.only(
                                    top: 5.h, right: 10.w, left: 10.w, bottom: 5.h),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      const SBH10(),
                                      Text("Subjects",
                                          style: GoogleFonts.roboto(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w300,
                                              color: const Color.fromRGBO(
                                                  52, 94, 168, 1))),
                                      const SBH5(),
                                      Text(getSringfromSubjectArray(
                                          dataModel.subject!, subData),
                                          style: GoogleFonts.roboto(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w400,
                                              color: const Color.fromRGBO(
                                                  98, 98, 98, 1))),
                                      const SBH10(),
                                      Divider(color: const Color.fromRGBO(
                                          61, 78, 176, 0.09), height: 1.h,),
                                      const SBH10(),
                                      Text("Standard",
                                          style: GoogleFonts.roboto(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w300,
                                              color: const Color.fromRGBO(
                                                  52, 94, 168, 1))),
                                      const SBH5(),
                                      Text("Std - ${dataModel.stdName}",
                                          style: GoogleFonts.roboto(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w400,
                                              color: const Color.fromRGBO(
                                                  98, 98, 98, 1))),
                                      const SBH10(),
                                      Divider(color: const Color.fromRGBO(
                                          61, 78, 176, 0.09), height: 1.h,),
                                      const SBH10(),
                                      Text("Tution Type",
                                          style: GoogleFonts.roboto(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w300,
                                              color: const Color.fromRGBO(
                                                  52, 94, 168, 1))),
                                      const SBH5(),
                                      Text(tutType,
                                          style: GoogleFonts.roboto(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w400,
                                              color: const Color.fromRGBO(
                                                  98, 98, 98, 1))),
                                      const SBH10(),
                                      Divider(color: const Color.fromRGBO(
                                          61, 78, 176, 0.09), height: 1.h,),
                                      ttt ? Container() : Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .start,
                                          children: [
                                            const SBH10(),
                                            Align(alignment: Alignment.topLeft,
                                                child: Text("Selected Hours",
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight
                                                            .w300,
                                                        color: const Color
                                                            .fromRGBO(
                                                            52, 94, 168, 1)))),
                                            const SBH5(),
                                            Align(alignment: Alignment.topLeft,
                                                child: Text(ss,
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight
                                                            .w400,
                                                        color: const Color
                                                            .fromRGBO(
                                                            98, 98, 98, 1)))),
                                            const SBH10(),
                                             Divider(color: const Color.fromRGBO(
                                                61, 78, 176, 0.09), height: 1.h,),
                                          ]),
                                      const SBH10(),
                                      if(dataModel.status == "Pending")
                                        Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start, children: [
                                          Align(alignment: Alignment.topLeft,
                                              child: Text("Fees Payment Status",
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight
                                                          .w300,
                                                      color: const Color
                                                          .fromRGBO(
                                                          52, 94, 168, 1)))),
                                          const SBH5(),
                                          Align(alignment: Alignment.topLeft,
                                              child: Text("Pending",
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight
                                                          .w400,
                                                      color: const Color
                                                          .fromRGBO(
                                                          239, 162, 137, 1))))
                                        ])
                                      else
                                        Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text("Payment Details",
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight
                                                          .w300,
                                                      color: const Color
                                                          .fromRGBO(
                                                          52, 94, 168, 1))),
                                              const SBH5(),
                                              Table(children: [
                                                TableRow(children: [
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                "Payment Amount",
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 16.sp,
                                                                    fontWeight: FontWeight
                                                                        .w300,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        152,
                                                                        152,
                                                                        152,
                                                                        1)))))
                                                  ]),
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                dataModel
                                                                    .amount!,
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 18.sp,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        98, 98,
                                                                        98,
                                                                        1)))))
                                                  ])
                                                ]),
                                                TableRow(children: [
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                "Payment Date",
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 16.sp,
                                                                    fontWeight: FontWeight
                                                                        .w300,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        152,
                                                                        152,
                                                                        152,
                                                                        1)))))
                                                  ]),
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                dataModel
                                                                    .datetime!,
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 18.sp,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        98, 98,
                                                                        98,
                                                                        1)))))
                                                  ])
                                                ]),
                                                TableRow(children: [
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                "Payment Method",
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 16.sp,
                                                                    fontWeight: FontWeight
                                                                        .w300,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        152,
                                                                        152,
                                                                        152,
                                                                        1)))))
                                                  ]),
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                "Stripe",
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 18.sp,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        98, 98,
                                                                        98,
                                                                        1)))))
                                                  ])
                                                ]),
                                                TableRow(children: [
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                "Transaction Id",
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 16.sp,
                                                                    fontWeight: FontWeight
                                                                        .w300,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        152,
                                                                        152,
                                                                        152,
                                                                        1)))))
                                                  ]),
                                                  Column(children: [
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .only(bottom: 2.h),
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                dataModel
                                                                    .transactionId!,
                                                                style: GoogleFonts
                                                                    .roboto(
                                                                    fontSize: 18.sp,
                                                                    fontWeight: FontWeight
                                                                        .w400,
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        98, 98,
                                                                        98,
                                                                        1)))))
                                                  ])
                                                ]),
                                              ],)
                                            ])
                                    ],),))))
                      ]),
                  ]));
        });
  }

  static requestAcceptDialog(List<SubjectDataModel> sub,
      List<HoursAvailData> hrs, BuildContext context, StudentData student) {
    var hours = getHourssepComma(hrs, student.aHours!, student.mHours!);
    var std = student.standard;
    var tutType = "";
    if (student.tuitionType! == "1") {
      tutType = "Online";
    } else if (student.tuitionType! == "2") {
      tutType = "Offline";
    } else if (student.tuitionType! == "3") {
      tutType = "Both";
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              insetPadding: EdgeInsets.all(12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: ListView(children: [
                Column(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.only(right: 4.w, top: 4.h),
                          child: Align(alignment: Alignment.topRight, child:
                          IconButton(icon: Icon(
                              Icons.clear, size: 27.h, color: const Color(0xffcccccc)),
                            onPressed: () {
                              Navigator.pop(context);
                            },))),
                      Row(children: [
                        Padding(padding: EdgeInsets.only(left: 15.w), child:
                        Align(alignment: Alignment.topLeft, child:
                        CircleAvatar(
                            radius: 37.r,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: Image.network(
                                  student.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('assets/Images/ic_avtar.png')
                              ),
                            )))),
                        Padding(padding: EdgeInsets.only(left: 10.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.username!,
                                    style: GoogleFonts.roboto(
                                        fontSize: 19.sp,
                                        color: const Color.fromRGBO(
                                          98, 98, 98, 1,),
                                        fontWeight: FontWeight.w500)),
                                const SBH5(),
                                Text(student.mobileNo!,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18.sp,
                                        color: const Color.fromRGBO(
                                            152, 152, 152, 1))),
                              ],)),
                      ],),
                      student.pStatus != "Paid" ? Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(padding: EdgeInsets.only(
                              right: 10.h, top: 10.h), child: SizedBox(
                            width: 195.w,
                            height: 40.h, child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r)),
                              color: appColor,
                              elevation: 0, child: Align(
                              alignment: Alignment.center,
                              child: Text("Send Fees Request",
                                  style: GoogleFonts.roboto(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white)
                              ))),
                          ))) : Container(),
                      Padding(padding: EdgeInsets.all(10.h), child:
                      SizedBox(
                          width: double.infinity,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),),
                              elevation: 0,
                              color: const Color.fromRGBO(248, 248, 255, 1),
                              child: Padding(padding: EdgeInsets.only(
                                  top: 5.h, right: 10.w, left: 10.w, bottom: 5.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SBH10(),
                                    Text("Subjects",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w300,
                                            color: const Color.fromRGBO(
                                                52, 94, 168, 1))),
                                    const SBH5(),
                                    Text(getSringfromSubjectArray(
                                        student.subject!, sub),
                                        style: GoogleFonts.roboto(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromRGBO(
                                                98, 98, 98, 1))),
                                    const SBH10(),
                                    Divider(
                                      color: const Color.fromRGBO(61, 78, 176, 0.09),
                                      height: 1.h,),
                                    const SBH10(),
                                    Text("Standard",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w300,
                                            color: const Color.fromRGBO(
                                                52, 94, 168, 1))),
                                    const SBH5(),
                                    Text("Std - $std",
                                        style: GoogleFonts.roboto(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromRGBO(
                                                98, 98, 98, 1))),
                                    const SBH10(),
                                    Divider(
                                      color: const Color.fromRGBO(61, 78, 176, 0.09),
                                      height: 1.h,),
                                    const SBH10(),
                                    Text("Tution Type",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w300,
                                            color: const Color.fromRGBO(
                                                52, 94, 168, 1))),
                                    const SBH5(),
                                    Text(tutType,
                                        style: GoogleFonts.roboto(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromRGBO(
                                                98, 98, 98, 1))),
                                    const SBH10(),
                                    Divider(
                                      color: const Color.fromRGBO(61, 78, 176, 0.09),
                                      height: 1.h,),
                                    const SBH10(),
                                    Text("Selected Hours",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w300,
                                            color: const Color.fromRGBO(
                                                52, 94, 168, 1))),
                                    const SBH5(),
                                    Text(hours,
                                        style: GoogleFonts.roboto(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400,
                                            color: const Color.fromRGBO(
                                                98, 98, 98, 1))),
                                    const SBH10(),
                                    Divider(
                                      color: const Color.fromRGBO(61, 78, 176, 0.09),
                                      height: 1.h,),
                                    const SBH10(),
                                    Text("Fees Payment Status",
                                        style: GoogleFonts.roboto(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w300,
                                            color: const Color.fromRGBO(
                                                52, 94, 168, 1))),
                                    const SBH5(),
                                    Text(student.pStatus! == "Paid" ? "Paid" : "Pending",
                                        style: GoogleFonts.roboto(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400,
                                            color: student.pStatus! == "Paid"
                                                ? const Color.fromRGBO(12, 175, 89, 1)
                                                : const Color.fromRGBO(
                                                239, 162, 137, 1))),
                                    Divider(
                                      color: const Color.fromRGBO(61, 78, 176, 0.09),
                                      height: 1.h,),
                                    const SBH10(),
                                    Column(mainAxisAlignment: MainAxisAlignment
                                        .start, children: [
                                      Align(alignment: Alignment.topLeft,
                                          child: Text("Address",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w300,
                                                  color: const Color.fromRGBO(
                                                      52, 94, 168, 1)))),
                                      const SBH5(),
                                      Align(alignment: Alignment.topLeft,
                                          child: Text(student.location!,
                                              style: GoogleFonts.roboto(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromRGBO(
                                                      98, 98, 98, 1))))
                                    ])
                                  ],),))))
                    ]),
              ]));
        }
    );
  }

  static myStudentDialog(List<SubjectDataModel> sub, List<HoursAvailData> hrs,
      StudentData student, BuildContext context) {
    var hours = getHourssepComma(hrs, student.aHours!, student.mHours!);
    var std = student.standard;
    var tutType = "";
    if (student.tuitionType! == "1") {
      tutType = "Online";
    } else if (student.tuitionType! == "2") {
      tutType = "Offline";
    } else if (student.tuitionType! == "3") {
      tutType = "Both";
    }

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              insetPadding: EdgeInsets.all(12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: ListView(
                  children: [ Column(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(right: 4.w, top: 4.h),
                            child: Align(alignment: Alignment.topRight, child:
                            IconButton(icon: Icon(
                                Icons.clear, size: 27.h, color: const Color(
                                0xffcccccc)),
                              onPressed: () {
                                Navigator.pop(context);
                              },))),
                        Column(children: [
                          Align(alignment: Alignment.topCenter, child:
                          CircleAvatar(
                              radius: 37.r,
                              backgroundColor: Colors.transparent,
                              child: ClipOval(
                                child: Image.network(
                                    student.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                        stackTrace) =>
                                        Image.asset(
                                            'assets/Images/ic_avtar.png')
                                ),
                              ))),
                          Column(
                            children: [
                              Text(student.username!, style: GoogleFonts.roboto(
                                  fontSize: 19.sp,
                                  color: const Color.fromRGBO(98, 98, 98, 1,),
                                  fontWeight: FontWeight.w500)),
                              const SBH5(),
                              Text(student.mobileNo!, style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18.sp,
                                  color: const Color.fromRGBO(
                                      152, 152, 152, 1))),
                            ],),
                        ],),
                        Align(alignment: Alignment.topCenter, child:
                        ClipPath(
                          clipper: Triangle(),
                          child: Container(
                            color: const Color.fromRGBO(248, 248, 255, 1),
                            width: 20.w,
                            height: 8.h,
                          ),
                        )),
                        Padding(
                            padding: EdgeInsets.only(left: 10.w, right: 10.w),
                            child:
                            SizedBox(
                                width: double.infinity,
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),),
                                    elevation: 0,
                                    color: const Color.fromRGBO(
                                        248, 248, 255, 1),
                                    child: Padding(padding: EdgeInsets
                                        .only(
                                        top: 5.h, right: 10.w, left: 10.w, bottom: 5.h),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          const SBH10(),
                                          Text("Subjects",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w300,
                                                  color: const Color.fromRGBO(
                                                      52, 94, 168, 1))),
                                          const SBH5(),
                                          Text(getSringfromSubjectArray(
                                              student.subject!, sub),
                                              style: GoogleFonts.roboto(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromRGBO(
                                                      98, 98, 98, 1))),
                                          const SBH10(),
                                          Divider(color: const Color.fromRGBO(
                                              61, 78, 176, 0.09), height: 1.h,),
                                          const SBH10(),
                                          Text("Standard",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w300,
                                                  color: const Color.fromRGBO(
                                                      52, 94, 168, 1))),
                                          const SBH5(),
                                          Text("Std - $std",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromRGBO(
                                                      98, 98, 98, 1))),
                                          const SBH10(),
                                          Divider(color: const Color.fromRGBO(
                                              61, 78, 176, 0.09), height: 1.h,),
                                          const SBH10(),
                                          Text("Tution Type",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w300,
                                                  color: const Color.fromRGBO(
                                                      52, 94, 168, 1))),
                                          const SBH5(),
                                          Text(tutType,
                                              style: GoogleFonts.roboto(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromRGBO(
                                                      98, 98, 98, 1))),
                                          const SBH10(),
                                          Divider(color: const Color.fromRGBO(
                                              61, 78, 176, 0.09), height: 1.h,),
                                          const SBH10(),
                                          Text("Selected Hours",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w300,
                                                  color: const Color.fromRGBO(
                                                      52, 94, 168, 1))),
                                          const SBH5(),
                                          Text(hours,
                                              style: GoogleFonts.roboto(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color.fromRGBO(
                                                      98, 98, 98, 1))),
                                          const SBH10(),
                                          Divider(color: const Color.fromRGBO(
                                              61, 78, 176, 0.09), height: 1.h,),
                                          const SBH10(),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start, children: [
                                            Align(alignment: Alignment.topLeft,
                                                child: Text(
                                                    "Fees Payment Status",
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight
                                                            .w300,
                                                        color: const Color
                                                            .fromRGBO(
                                                            52, 94, 168, 1)))),
                                            const SBH5(),
                                            if(student.status == "Paid")
                                              ssselse()
                                            else
                                              sss(student.studentEmail!),
                                          ]),
                                          Divider(color: const Color.fromRGBO(
                                              61, 78, 176, 0.09), height: 1.h,),
                                          const SBH10(),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .start, children: [
                                            Align(alignment: Alignment.topLeft,
                                                child: Text("Address",
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight
                                                            .w300,
                                                        color: const Color
                                                            .fromRGBO(
                                                            52, 94, 168, 1)))),
                                            const SBH5(),
                                            Align(alignment: Alignment.topLeft,
                                                child: Text(student.location!,
                                                    style: GoogleFonts.roboto(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight
                                                            .w400,
                                                        color: const Color
                                                            .fromRGBO(
                                                            98, 98, 98, 1))))
                                          ])
                                        ],),))))
                      ]),
                  ])
          );
        }
    );
  }

  static Widget sss(String stEmail) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Align(alignment: Alignment.topLeft, child: Text("Pending",
          style: GoogleFonts.roboto(
              fontSize: 18.sp, fontWeight: FontWeight.w400,
              color: const Color.fromRGBO(239, 162, 137, 1)))),
      GestureDetector(onTap: () async {
        CustomDialog.processDialog(
          loadingMessage: "Send Request...",
          successMessage: "Request Sended Successfully",
        );

        final result1 = await MyServices.sendFeesRequest(stEmail
        ).catchError(
              // ignore: body_might_complete_normally_catch_error
              (error, stackTrace) {
            myController.isProcessDone.value = 0;
            myController.processErrorMessage.value = error.toString();
          },
        );
        if (result1 != null) {
          if (result1.status!) {
            myController.isProcessDone.value = 2;
          } else {
            myController.isProcessDone.value = 0;
            myController.processErrorMessage.value = result1.msg!;
          }
        }
      }, child: Align(alignment: Alignment.bottomRight,
          child: SizedBox(
            width: 120.w,
            height: 40.h, child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r)),
              color: appColor,
              elevation: 0,
              child: Align(
                  alignment: Alignment.center, child: Text("Send Request",
                  style: GoogleFonts.roboto(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white)
              ))),
          )))
    ]);
  }

  static Widget ssselse() {
    return Column(children: [
      Align(alignment: Alignment.topLeft, child: Text("Received",
          style: GoogleFonts.roboto(
              fontSize: 18.sp, fontWeight: FontWeight.w400,
              color: const Color.fromRGBO(12, 175, 89, 1)))),
      const SBH10(),
    ],);
  }

  static notificationDilog(BuildContext context, String title, String msg) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              insetPadding: EdgeInsets.all(12.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: 300.w,
                height: 200.h,
                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.only(right: 4.w, top: 4.h),
                          child: Align(alignment: Alignment.topRight,
                              child: IconButton(icon: Icon(
                                  Icons.clear, size: 27.h,
                                  color: const Color(0xffcccccc)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },))),
                      Text(textAlign: TextAlign.center,
                        title,
                        style: GoogleFonts.roboto(
                            color: const Color.fromRGBO(98, 98, 98, 1),
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp),),
                      Text(msg, style: GoogleFonts.roboto(
                          color: const Color.fromRGBO(152, 152, 152, 1),
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp),),
                      const SBH10(),
                      const SBH10(),
                      SizedBox(
                          width: 110.w,
                          height: 40.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0, backgroundColor: appColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)
                                ),
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal)),
                            onPressed: () async {
                              Navigator.pop(context);
                              Get.to(() => const MyTutorListPage(),);
                            },
                            child: const Text(
                              "Ok",
                            ),
                          )),
                    ]
                ),)
          );
        }
    );
  }

  static ratingDilog(BuildContext context, String tutorEmail, String rating) {
    var rat = "0";
    if(rating.isEmpty){
      rat = "1";
    }else{
      rat = rating;
    }
    BuildContext dialogContext;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          dialogContext = context;
          return Dialog(
              insetPadding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: 300.w,
                height: 170.h,
                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.only(right: 4.w, top: 4.h),
                          child: Align(alignment: Alignment.topRight,
                              child: IconButton(icon: Icon(
                                  Icons.clear, size: 27.h,
                                  color: const Color(0xffcccccc)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },))),
                      RatingBar.builder(
                        initialRating: double.parse(rat),
                        minRating: 1,
                        unratedColor: const Color.fromRGBO(204, 204, 204, 1),
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(
                            horizontal: 4.h),
                        itemBuilder: (context, _) =>
                        const Icon(
                          Icons.star,
                          color: Color.fromRGBO(246, 189, 96, 1),
                        ),
                        onRatingUpdate: (rating) {
                          rat = rating.toString();
                        },
                      ),
                      const SBH10(),
                      const SBH10(),
                      SizedBox(
                          width: 110.w,
                          height: 40.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0, backgroundColor: appColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)
                                ),
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal)),
                            onPressed: () async {
                              CustomDialog.processDialog(
                                loadingMessage: "Processing",
                                successMessage: "Rating added Successfully",
                              );

                              final result1 = await MyServices.addRating(rat,
                                  tutorEmail
                              ).catchError(
                                    // ignore: body_might_complete_normally_catch_error
                                    (error, stackTrace) {
                                  myController.isProcessDone.value = 0;
                                  myController.processErrorMessage.value =
                                      error.toString();
                                },
                              );
                              if (result1 != null) {
                                if (result1.status!) {
                                  myController.isProcessDone.value = 2;
                                  SharedPred.setTutorRating(rat, tutorEmail);
                                  if(dialogContext.mounted){
                                    Navigator.pop(dialogContext);
                                    Navigator.pop(dialogContext,rat);
                                  }else{
                                    return;
                                  }
                                } else {
                                  myController.isProcessDone.value = 0;
                                  myController.processErrorMessage.value =
                                  result1.msg!;
                                }
                              }
                            },
                            child: const Text(
                              "Submit",
                            ),
                          )),
                    ]
                ),
              )
          );
        }
    );
  }

  static requestSendDilog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
              insetPadding: EdgeInsets.all(12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: 300.w,
                height: 180.h,
                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.only(right: 4.w, top: 4.h),
                          child: Align(alignment: Alignment.topRight,
                              child: IconButton(icon: Icon(
                                  Icons.clear, size: 27.h,
                                  color: const Color(0xffcccccc)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },))),
                      Column(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/Anim/check.gif",
                              height: 80.h,
                              width: 80.w,
                            ),

                            Text("Request Send Succesfully!",
                                style: GoogleFonts.roboto(
                                    fontSize: 17.sp, fontWeight: FontWeight.w500,
                                    color: const Color.fromRGBO(
                                        52, 94, 168, 1))),
                          ]
                      )
                    ]
                ),
              ));
        }
    );
  }

  static Widget errorDialog(
      {required String title, required Color progressColor}) {
    return Column(
      children: [
        Lottie.asset(
          "assets/Anim/error.json",
          width: 70.w,
          height: 70.h,
        ),
        Text(
          title,
          style: GoogleFonts.roboto(fontSize: 14.sp,color: Colors.black),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: progressColor,
          ),
          child: const Text(
            "Got it !",
          ),
        )
      ],
    );
  }

  static Widget loadingDialog(
      {required String title, required Color progressColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircularProgressIndicator(
          color: progressColor,
        ),
        Text(
          title,
          style: Get.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget successDialog({
    required String title,
    required Color progressColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Lottie.asset(
          "assets/Anim/blue_right.json",
          width: 45.w,
          height: 45.h,
          repeat: false,
          frameRate: FrameRate(60),
        ),
        Text(
          title,
          style: Get.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static void processDialog({
    required String loadingMessage,
    required String successMessage,
  }) {
    myController.isProcessDone.value = 1;
    Get.dialog(
      WillPopScope(
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 200.h,
            width: 200.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Obx(
                  () {
                if (myController.isProcessDone.value == 1) {
                  return loadingDialog(
                    title: loadingMessage,
                    progressColor: appColor,
                  );
                } else if (myController.isProcessDone.value == 2) {
                  return successDialog(
                    title: successMessage,
                    progressColor: appColor,
                  );
                } else {
                  return errorDialog(
                    title: myController.processErrorMessage.value,
                    progressColor: appColor,
                  );
                }
              },
            ),
          ),
        ),
        onWillPop: () => Future.value(false),
      ),
      barrierDismissible: false,
      useSafeArea: true,
    );
  }

  static Future<void> cancelDialog() async {
    await Future.delayed(
      const Duration(seconds: 1),
          () {
        Get.back();
      },
    );
  }
}
