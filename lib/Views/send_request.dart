import 'dart:convert';

import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Models/hours_avail_model.dart';
import 'package:e_tutor/Models/subject_model.dart';
import 'package:e_tutor/Models/tutor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Helper/helper.dart';
import '../Models/standard.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CustomWidgets/handle_errors_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyRequestListPage extends StatefulWidget {
  const MyRequestListPage(
      {Key? key})
      : super(key: key);

  @override
  State<MyRequestListPage> createState() => _MyRequestListPageState();
}

class _MyRequestListPageState extends State<MyRequestListPage> {
  Future<TutorModel?>? tutorData;
  List<SubjectDataModel> subData = [];
  List<HoursAvailData> hrsData = [];
  List<StandardDataModel> stdData = [];
  String? data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdata();
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
            fetchRequestedTutor();
        });
      });
    });
  }

  void fetchRequestedTutor() {
    setState(() {
      tutorData = MyServices.getTutorList("my_request");
      data = "success";
    });
  }

  @override
  Widget build(BuildContext context) {
    PaintingBinding.instance.imageCache.clear();
    String? title = "Send Request";
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
            leading:  IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 25.h,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              title,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 19.sp),
            ),
            backgroundColor: appColor,
            shape: CustomAppBarShape(multi: 0.08.h),
          )),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(20.h),
          child: TextFormField(
            textAlign: TextAlign.start,
            keyboardType: TextInputType.text,
            cursorColor: appColor,
            textAlignVertical: TextAlignVertical.center,
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
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
              prefixIcon: const Icon(Icons.search_sharp,
                  color: Color.fromARGB(255, 204, 204, 204)),
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
            child: FutureBuilder<TutorModel?>(
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
                      // controller: _controller,//new line
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
                                        flex: 1,
                                        child: Padding(
                                            padding: EdgeInsets.all(
                                                10.h),
                                            child: Container(
                                                height: 71.h,
                                                width: 71.w,
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
                                        flex: 3,
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
    );
  }
}