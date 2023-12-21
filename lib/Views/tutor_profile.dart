import 'dart:convert';
import 'package:e_tutor/Views/bottom_navigation_tutor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Models/subject_model.dart';
import 'package:e_tutor/Views/CustomWidgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import '../Helper/helper.dart';
import 'package:dotted_line/dotted_line.dart';
import '../Models/hours_avail_model.dart';
import '../Models/standard.dart';
import '../Models/tutor_detail_model.dart';
import '../Services/my_services.dart';
import 'CustomDrawer/custom_tutor_drawer.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/custom_dialogs.dart';
import 'CustomWidgets/custom_text_form_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CustomWidgets/triangle.dart';
import 'CustomWidgets/utilss.dart';
import 'dart:io';
import 'bottom_navigation.dart';
import 'notification_page.dart';

class TutorProfile extends StatefulWidget {
  final int type;

  const TutorProfile({Key? key, required this.type }) : super(key: key);

  @override
  State<TutorProfile> createState() => _TutorProfileState();

}

class _TutorProfileState extends State<TutorProfile>
    with SingleTickerProviderStateMixin {
  late int selectedRadio = 1;
  late ScrollController _scrollController;
  Data? tutorData;
  final formKey = GlobalKey<FormState>();
  String selectedStd = "",
      selectedSub = "",
      selectedFees = "",
      mHrs = "",
      aHrs = "",
      email = "",
      username = "",
      location = "",
      mobile = "",
      image = "",
      uni = "",
      exp = "";
  CroppedFile? imageFile;
  String? _data;
  List<HoursAvailData> hoursList = [];
  List<StandardDataModel> stdList = [];
  List<SubjectDataModel> subList = [];
  final List<HoursAvailData> hoursAvailAM = [];
  final List<HoursAvailData> hoursAvailPM = [];
  final List<TextEditingController> _nameController = [];
  int iniIndex = 0;
  Position? aa;

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  TextEditingController userCn = TextEditingController();
  TextEditingController mobCn = TextEditingController();
  final ValueNotifier<bool> _counterMob = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _counterUser = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    // final adUnitId = Platform.isAndroid
    //     ? banner_ad_id
    //     : banner_ad_id_ios;
    // bannerAd = BannerAd(
    //   adUnitId: adUnitId,
    //   request: AdRequest(),
    //   listener: listener,
    //   size: AdSize.banner,
    // );
    // bannerAd?.load();
    // adWidget = AdWidget(ad: bannerAd!);

    _scrollController = ScrollController();
    SharedPred.getSubjectModel().then((value) {
      subList = (json.decode(value!) as List)
          .map((data) => SubjectDataModel.fromJson(data))
          .toList();
      SharedPred.getStandardModel().then((value) {
        stdList = (json.decode(value!) as List)
            .map((data) => StandardDataModel.fromJson(data))
            .toList();
        SharedPred.getHoursModel().then((value) {
          hoursList = (json.decode(value!) as List)
              .map((data) => HoursAvailData.fromJson(data))
              .toList();

          for (int i = 0; i < hoursList.length; i++) {
            if (hoursList[i].session == "am") {
              hoursAvailAM.add(hoursList[i]);
            } else {
              hoursAvailPM.add(hoursList[i]);
            }
          }

          SharedPred.getTutorDetail().then((value) {
              List<dynamic> list = json.decode(value!);

            if(list.isEmpty){}else {
              Data tutorData = Data.fromJson(list[0]);
              selectedRadio = int.parse(tutorData.tuitionType!);
              image = tutorData.image!;
              mobile = tutorData.mobileNo!;
              exp = tutorData.yearOfExperience!;
              location = tutorData.location!;
              username = tutorData.username!;
              email = tutorData.email!;
              uni = tutorData.university!;
              aHrs = tutorData.aHours!;
              mHrs = tutorData.mHours!;
              selectedFees = tutorData.monthlyFees!;
              selectedSub = tutorData.subject!;
              selectedStd = tutorData.standard!;

              mobCn = TextEditingController(text: mobile);
              userCn = TextEditingController(text: username);

              final splitStd = selectedStd.split(',');
              final Map<int, String> valuesStd = {
                for (int i = 0; i < splitStd.length; i++)
                  i: splitStd[i]
              };

              for (int j = 0; j < stdList.length; j++) {
                for (int k = 0; k < valuesStd.length; k++) {
                  if (valuesStd[k] == stdList[j].id) {
                    stdList[j].isSelected = true;
                  }
                }
              }

              final splitAHrs = aHrs.split(',');
              final splitMHrs = mHrs.split(',');
              final Map<int, String> valueAHrs = {
                for (int i = 0; i < splitAHrs.length; i++)
                  i: splitAHrs[i]
              };
              final Map<int, String> valueMHrs = {
                for (int i = 0; i < splitMHrs.length; i++)
                  i: splitMHrs[i]
              };

              for (int j = 0; j < hoursAvailAM.length; j++) {
                for (int k = 0; k < valueMHrs.length; k++) {
                  if (valueMHrs[k] == hoursAvailAM[j].id) {
                    hoursAvailAM[j].isSelected = true;
                  }
                }
              }

              for (int j = 0; j < hoursAvailPM.length; j++) {
                for (int k = 0; k < valueAHrs.length; k++) {
                  if (valueAHrs[k] == hoursAvailPM[j].id) {
                    hoursAvailPM[j].isSelected = true;
                  }
                }
              }

              final split = selectedSub.split(',');
              final Map<int, String> values = {
                for (int i = 0; i < split.length; i++)
                  i: split[i]
              };

              final splitFees = selectedFees.split(',');
              final Map<int, String> valuesFees = {
                for (int i = 0; i < splitFees.length; i++)
                  i: splitFees[i]
              };

              for (int j = 0; j < subList.length; j++) {
                for (int k = 0; k < values.length; k++) {
                  if (values[k] == subList[j].id) {
                    subList[j].isSelected = true;
                    subList[j].price = valuesFees[k]!;
                  }
                }
              }
            }
              setState(() {
                _data = "success";
              });

          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return _data == null ? const Center(
        child: CircularProgressIndicator(color: appColor,)) : Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight((size.height / 10)),
          child: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: appColor,
              statusBarColor: appColor,
            ),
            titleSpacing: 30.h,
            leading: Builder(builder: (context) =>
                IconButton(
                  icon: Icon(size : 20.h,Icons.notes_rounded, color: Colors.white,),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
            ),
            actions: <Widget>[
              Align(alignment: Alignment.centerRight,
                  child: IconButton(onPressed: () {
                    Get.to(() => const NotificationPage());
                  },
                      icon: Icon(
                        Icons.notifications,size: 20.h, color: Colors.white,)))
            ],
            title: Text("School Profile", style: GoogleFonts.roboto(
                color: Colors.white, fontWeight: FontWeight.w500,
                fontSize: 19.sp),),
            backgroundColor: appColor,
            shape: CustomAppBarShape(multi: 0.08.h),),
        ),
        drawer: const CustomDrawerTutor(),
        body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, value) {
              return [
                SliverToBoxAdapter(child: Column(
                  children: <Widget>[
                    const SBH5(),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Select image type",
                                    style: TextStyle(fontSize: 18.sp,
                                        color: appColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  actionsAlignment: MainAxisAlignment.start,
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          elevation: 0
                                      ),
                                      child: Text("Take Image From Gallery",
                                        style: TextStyle(color: appColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w200),),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        // _getImage(1);
                                        // Step #1: Pick Image From Galler.
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
                                          elevation: 0
                                      ),
                                      child: Text(
                                        "Capture Images From Camera",
                                        style: TextStyle(color: appColor,fontSize: 14.sp,
                                            fontWeight: FontWeight.w200),),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await Utils.pickImageFromCamera().then((
                                            pickedFile) async {
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
                          }, child:
                      Stack(children: [
                        Container(
                            child: imageFile != null
                                ? CircleAvatar(
                                radius: 60.r, child: ClipOval(child: Image.file(
                                File(imageFile!.path)),
                            )) :
                            Container(
                              child: image == "" ?
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                const AssetImage("assets/Images/ic_avtar.png"),
                                radius: 60.r,
                              ) :
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 60.r,
                                child: ClipOval(
                                  child: Image.network(
                                      image,
                                      errorBuilder: (context, error,
                                          stackTrace) =>
                                          Image.asset(
                                              'assets/Images/ic_avtar.png')
                                  ),
                                ),
                              ),
                            )),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Padding(padding: EdgeInsets.only(bottom: 5.h),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 2.w, color: Colors.black)
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 15.r,
                                      child: Icon(Icons.edit,size: 15.h,),
                                    )))),
                      ])),
                    ),
                    const SBH10(),
                    Align(alignment: Alignment.center, child: Text(
                        email, style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        color: appColor,
                        fontWeight: FontWeight.w500
                    ))),
                    const SBH10(),
                    Padding(
                        padding: EdgeInsets.only(left: 20.w, right: 20.w),
                        child:
                        Form(
                            key: formKey,
                            child: Column(
                                children: [
                                  ValueListenableBuilder<bool>(
                            builder:
                            (BuildContext context, bool value, Widget? child) {
                        return
                        Visibility(visible : _counterUser.value ,child: Align(alignment: Alignment.topLeft,
                        child : Text("Enter Username"
                        ,style: TextStyle(fontSize: 11.sp,color: Colors.red,fontWeight: FontWeight.w400),)));
                        },valueListenable: _counterUser),
                        const SBH5(),
                        TFF(
                            controler: userCn,
                                    color: const Color.fromRGBO(
                                        61, 78, 176, 0.09),
                                    align: TextAlign.center,
                                    hintText: "User Name",
                                    keyboardType: TextInputType.text,
                                    onSaved: (data) {
                                      username = data!.trim();
                                    },),

                                  const SBH10(),ValueListenableBuilder<bool>(
                                      builder:
                                          (BuildContext context, bool value, Widget? child) {
                                        return
                                          Visibility(visible : _counterMob.value ,child: Align(alignment: Alignment.topLeft,
                                              child : Text("Enter Mobile number"
                                                ,style: TextStyle(fontSize: 11.sp,color: Colors.red,fontWeight: FontWeight.w400),)));
                                      },valueListenable: _counterMob),
                                  TFF(
                                    controler: mobCn,
                                    color: const Color.fromRGBO(
                                        61, 78, 176, 0.09),
                                    align: TextAlign.center,
                                    hintText: "Mobile Number",
                                    keyboardType: TextInputType.number,
                                    onSaved: (data) {
                                      mobile = data!.trim();
                                    },),
                                  const SBH10(),
                                  StatefulBuilder(
                                    builder: (context, passState) {
                                      return TFF(
                                        initialValue: location,
                                        color: const Color.fromRGBO(
                                            61, 78, 176, 0.09),
                                        align: TextAlign.center,
                                        hintText: "Address",
                                        onSaved: (data) {
                                          location = data!.trim();
                                        },
                                      );
                                    },
                                  ),
                                  const SBH10(),
                                  StatefulBuilder(
                                    builder: (context, passState) {
                                      return TFF(
                                        initialValue: uni,
                                        color: const Color.fromRGBO(
                                            61, 78, 176, 0.09),
                                        align: TextAlign.center,
                                        hintText: "University",
                                        onSaved: (data) {
                                          uni = data!.trim();
                                        },
                                      );
                                    },
                                  ),
                                  const SBH10(),
                                  StatefulBuilder(
                                    builder: (context, passState) {
                                      return TFF(
                                        initialValue: exp,
                                        color: const Color.fromRGBO(
                                            61, 78, 176, 0.09),
                                        align: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        hintText: "Year of Experience",
                                        onSaved: (data) {
                                          exp = data!.trim();
                                        },
                                      );
                                    },
                                  )
                                ]
                            ))),
                    const SBH5(),
                    Row(mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              fit: FlexFit.loose,
                              child: ListTile(
                                  dense: true,
                                  title: Transform.translate(
                                    offset: Offset(-25.w, 0), child:
                                  Text("Online",
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                          color: const Color.fromRGBO(
                                              98, 98, 98, 1))),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  leading: Radio(
                                    visualDensity: const VisualDensity(
                                        horizontal: VisualDensity
                                            .minimumDensity,
                                        vertical: VisualDensity.minimumDensity),
                                    value: 1,
                                    groupValue: selectedRadio,
                                    activeColor: appColor,
                                    onChanged: (val) {
                                      setSelectedRadio(val!);
                                    },
                                  ))),
                          Flexible(
                              fit: FlexFit.loose,
                              child: ListTile(
                                dense: true,
                                title: Transform.translate(offset: Offset(
                                    -25.w, 0),
                                    child: Text(
                                        "Offline", style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                        color: const Color.fromRGBO(
                                            98, 98, 98, 1)))),
                                contentPadding: EdgeInsets.zero, leading:
                              Radio(
                                visualDensity: const VisualDensity(
                                    horizontal: VisualDensity.minimumDensity,
                                    vertical: VisualDensity.minimumDensity),
                                // title: Text("Offline"),
                                value: 2,
                                groupValue: selectedRadio,
                                activeColor: appColor,
                                onChanged: (val) {
                                  setSelectedRadio(val!);
                                },
                              ),)),
                          Flexible(
                              fit: FlexFit.loose,
                              child: ListTile(
                                dense: true,
                                title: Transform.translate(offset: Offset(
                                    -25.w, 0),
                                    child: Text(
                                        "Both", style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 17.sp,
                                        color: const Color.fromRGBO(98, 98, 98, 1)))),
                                contentPadding: EdgeInsets.zero, leading:
                              Radio(
                                visualDensity: const VisualDensity(
                                    horizontal: VisualDensity.minimumDensity,
                                    vertical: VisualDensity.minimumDensity),
                                // title: Text("Offline"),
                                value: 3,
                                groupValue: selectedRadio,
                                activeColor: appColor,
                                onChanged: (val) {
                                  setSelectedRadio(val!);
                                },
                              ),))
                        ]),
                    const SBH5(),
                  ],
                )),
                SliverToBoxAdapter(
                    child:
                    Container(
                        height: 45.h,
                        decoration: const BoxDecoration(
                          color: appColor,
                        ),
                        child: Row(children: [
                          Expanded(flex: 2, child: GestureDetector(onTap: () {
                            setState(() {
                              iniIndex = 0;
                            });
                          }, child: SizedBox(
                            height: 45.h,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    color: appColor,
                                    child: Align(alignment: Alignment.center,
                                        child: Text("Subject & Std",
                                          style: GoogleFonts.roboto(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w400,
                                              color: iniIndex == 0
                                                  ? appWhite
                                                  : const Color.fromRGBO(
                                                  204, 204, 204, 1)),)),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Divider(height: 1.h,
                                      thickness: 3.h,
                                      color: iniIndex == 0 ? const Color.fromRGBO(
                                          246, 189, 96, 1) : appColor,)
                                ),
                              ],
                            ),
                          ))),
                          Expanded(flex: 2, child: GestureDetector(onTap: () {
                            setState(() {
                              iniIndex = 1;
                            });
                          }, child: SizedBox(
                              height: 45.h,
                              child: Stack(
                                  children: [
                                    Positioned.fill(
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              Icon(Icons.person_add_alt_sharp,size: 15.h,
                                                  color: iniIndex == 1
                                                      ? appWhite
                                                      : const Color.fromRGBO(
                                                      204, 204, 204, 1)),
                                              Text("Availability",
                                                  style: GoogleFonts.roboto(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight
                                                          .w400,
                                                      color: iniIndex == 1
                                                          ? appWhite
                                                          : const Color.fromRGBO(
                                                          204, 204, 204, 1)))
                                            ]
                                        )),
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Divider(height: 1.h,
                                          thickness: 3.h,
                                          color: iniIndex == 1 ? const Color.fromRGBO(
                                              246, 189, 96, 1) : appColor,)
                                    ),
                                  ]
                              ))
                          )),
                        ],)
                    )),
              ];
            },
            body: Container(
                child: iniIndex == 0 ? Padding(
                    padding: EdgeInsets.only(top: 0.h, left: 10.w, right: 10.w),
                    child: ListView(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          Padding(padding: EdgeInsets.only(left: 55.w),
                              child: Align(alignment: Alignment.topLeft, child:
                              ClipPath(
                                clipper: Triangle(),
                                child: Container(
                                  color: const Color.fromRGBO(238, 239, 248, 1),
                                  width: 20.w,
                                  height: 10.h,
                                ),
                              ))),
                          Container(
                              padding: EdgeInsets.fromLTRB(
                                  10.w, 5.h, 10.w, 10.h),
                              //extra 10 for top padding because triangle's height = 10
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(238, 239, 248, 1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Column(children: [
                                Align(alignment: Alignment.topLeft,
                                    child: Text('Choose Subjects & Standards',
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17.sp,
                                            color: const Color.fromRGBO(
                                                98, 98, 98, 1)))),
                                const SBH10(),
                                Padding(padding: EdgeInsets.only(
                                    left: 10.w, right: 10.w), child:
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: subList.length,
                                  itemBuilder: (context, index) {
                                    _nameController.add(TextEditingController(
                                        text: subList[index].price));
                                    return CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        activeColor: appColor,
                                        tileColor: appColor,
                                        selectedTileColor: appColor,
                                        checkColor: Colors.white,
                                        dense: true,
                                        controlAffinity: ListTileControlAffinity
                                            .leading,
                                        secondary: Container(
                                            height: 30.h,
                                            width: 100.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius
                                                  .circular(8.r),
                                            ),
                                            child: Padding(
                                                padding: EdgeInsets.all(
                                                    5.w),
                                                child: TextFormField(
                                                    controller: _nameController[index],
                                                    // initialValue: subList[index].price,
                                                    keyboardType: TextInputType
                                                        .number,
                                                    decoration: const InputDecoration(
                                                        border: InputBorder
                                                            .none),
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 15.sp,
                                                      fontWeight: FontWeight
                                                          .w400,
                                                      color: const Color
                                                          .fromRGBO(
                                                          98, 98, 98, 1),)))),
                                        // subtitle: Text(price[index]),
                                        title: Transform.translate(
                                            offset: Offset(-15.w, 0),
                                            child: Text(
                                                subList[index].subjectName!,
                                                style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 17.sp,
                                                    color: const Color.fromRGBO(
                                                        98, 98, 98, 1)))),
                                        value: subList[index].isSelected,
                                        onChanged: (bool? newValue) {
                                          if (newValue == true) {
                                            setState(() {
                                              subList[index].isSelected = true;
                                            });
                                          } else {
                                            setState(() {
                                              subList[index].isSelected = false;
                                            });
                                          }
                                        });
                                  },
                                )
                                ),
                                const SBH5(),
                                SizedBox(height: 33.h, child:
                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  // physics: const ClampingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: stdList.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(onTap: () {
                                      setState(() {
                                        stdList[index].isSelected =
                                        !stdList[index].isSelected;
                                      });
                                    },
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 5.w, right: 5.w),
                                            child: Container(
                                                height: 33.h,
                                                width: 100.w,
                                                decoration: BoxDecoration(
                                                  color: stdList[index]
                                                      .isSelected
                                                      ? appColor
                                                      : Colors.white,
                                                  borderRadius: BorderRadius
                                                      .circular(20.r),
                                                ),
                                                child: Align(
                                                    alignment: Alignment.center,
                                                    child: Text("Std ${stdList[index].std!}",
                                                        style: GoogleFonts
                                                            .roboto(
                                                          fontSize: 15.sp,
                                                          fontWeight: FontWeight
                                                              .w400,
                                                          color: stdList[index]
                                                              .isSelected
                                                              ? Colors.white
                                                              : const Color
                                                              .fromRGBO(
                                                              98, 98, 98,
                                                              1),))))));
                                  },
                                ))
                              ],
                              )
                          ), Padding(padding: EdgeInsets.all(0.w), child:
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: appYellowButton,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.r)
                                    ),
                                    textStyle: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500)),
                                onPressed: () async {
                                  updateProfile();
                                },
                                child: const Text(
                                  "Update",
                                ),
                              ))),
                        ]))
                    :
                Padding(
                  padding: EdgeInsets.only(top: 5.h, left: 10.w, right: 10.w),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(right: 75.w),
                          child: Align(alignment: Alignment.topRight, child:
                          ClipPath(
                            clipper: Triangle(),
                            child: Container(
                              color: const Color.fromRGBO(238, 239, 248, 1),
                              width: 20.w,
                              height: 10.h,
                            ),
                          ))),
                      Container(
                          padding: EdgeInsets.fromLTRB(15.w, 10.h, 20.w, 15.h),
                          //extra 10 for top padding because triangle's height = 10
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(238, 239, 248, 1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(children: [
                            const SBH5(),
                            Align(alignment: Alignment.topLeft,
                                child: Text('Hours of Availability',
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17.sp,
                                        color: const Color.fromRGBO(
                                            98, 98, 98, 1)))),
                            const SBH10(),
                            const SBH5(),
                            Align(alignment: Alignment.topLeft,
                                child: Text('Morning Hours',
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14.sp,
                                        color: const Color.fromRGBO(
                                            152, 152, 152, 1)))),
                            const SBH5(),
                            SizedBox(height: 37.h, child:
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: hoursAvailAM.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        hoursAvailAM[index].isSelected =
                                        !hoursAvailAM[index].isSelected;
                                      });
                                    },
                                    child: SizedBox(
                                        height: 37.h,
                                        width: 91.w,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(width: 0.7.w,
                                                  color: const Color.fromRGBO(
                                                      52, 94, 168, 0.3)),
                                              borderRadius: BorderRadius
                                                  .circular(4.r)
                                          ),
                                          margin: EdgeInsets.only(
                                              left: 10.w, right: 10.w),
                                          elevation: 0,
                                          color: hoursAvailAM[index].isSelected
                                              ? appColor
                                              : Colors.white,
                                          child: Align(
                                              alignment: Alignment.center,
                                              child:
                                              Text(hoursAvailAM[index].hours!
                                                  .replaceAll(":00", ""),
                                                  style: GoogleFonts.roboto(
                                                      fontWeight: FontWeight
                                                          .w400,
                                                      fontSize: 17.sp,
                                                      color: hoursAvailAM[index]
                                                          .isSelected ? Colors
                                                          .white : const Color
                                                          .fromARGB(
                                                          98, 98, 98, 1))
                                              )),
                                        ))
                                );
                              },
                            )
                            ),
                            const SBH10(),
                            const SBH5(),
                            DottedLine(direction: Axis.horizontal,
                              lineLength: double.infinity,
                              lineThickness: 1.h,
                              dashLength: 4.w,
                              dashColor: Colors.white,),
                            const SBH10(),
                            const SBH5(),
                            Align(alignment: Alignment.topLeft,
                                child: Text('Afternoon Hours',
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14.sp,
                                        color: const Color.fromRGBO(
                                            152, 152, 152, 1)))),
                            const SBH5(),
                            SizedBox(height: 37.h, child:
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemCount: hoursAvailPM.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        hoursAvailPM[index].isSelected =
                                        !hoursAvailPM[index].isSelected;
                                      });
                                    },
                                    child: SizedBox(
                                        height: 37.h,
                                        width: 91.w,
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(width: 0.7.w,
                                                  color: const Color.fromRGBO(
                                                      52, 94, 168, 0.3)),
                                              borderRadius: BorderRadius
                                                  .circular(4.r)
                                          ),
                                          margin: EdgeInsets.only(
                                              left: 10.w, right: 10.w),
                                          elevation: 0,
                                          color: hoursAvailPM[index].isSelected
                                              ? appColor
                                              : Colors.white,
                                          child: Align(
                                              alignment: Alignment.center,
                                              child:
                                              Text(hoursAvailPM[index].hours!
                                                  .replaceAll(":00", ""),
                                                  style: GoogleFonts.roboto(
                                                      fontWeight: FontWeight
                                                          .w400,
                                                      fontSize: 17.sp,
                                                      color: hoursAvailPM[index]
                                                          .isSelected ? Colors
                                                          .white : const Color
                                                          .fromARGB(
                                                          98, 98, 98, 1))
                                              )),
                                        ))
                                );
                              },
                            )
                            ),
                          ],
                          )
                      ), const SBH10(),
                      const SBH10(),
                      const SBH10(),
                      Padding(padding: EdgeInsets.all(10.h), child:
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: appYellowButton,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r)
                                ),
                                textStyle: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500)),
                            onPressed: () async {
                              updateProfile();
                            },
                            child: const Text(
                              "Update",
                            ),
                          )))
                    ],
                  ),
                ))
        ),
    // bottomNavigationBar:  Container(
    //   alignment: Alignment.center,
    //   child: adWidget,
    //   width: bannerAd!.size.width.toDouble(),
    //   height: bannerAd!.size.height.toDouble(),)
      );
  }

  void updateProfile() async {
    double lati = 0;
    double long = 0;
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {

    } else if (permission == LocationPermission.deniedForever) {

    } else {
      await Geolocator.getCurrentPosition().then((value) {
        lati = value.latitude;
        long = value.longitude;
      });
    }

    formKey.currentState!.save();
    bool isValid = formKey.currentState!.validate();
    if(userCn.text == ""){
      _counterUser.value = true;
      return;
    }
    if(mobCn.text == ""){
      _counterMob.value = true;
      return;
    }
    if (isValid) {
      if (imageFile != null) {
        CustomDialog.processDialog(
          loadingMessage: "Set Profile image",
          successMessage: "Set Profile image Successfully",
        );
        final resultProfile = await MyServices
            .addStudentTutorProfileImg(imageFile!, "set_tutor_profile_image"
        ).catchError(
              // ignore: body_might_complete_normally_catch_error
              (error, stackTrace) {
            myController.isProcessDone
                .value = 0;
            myController.processErrorMessage
                .value = error.toString();
          },
        );
        if (resultProfile != null) {
          if (resultProfile.status!) {
            setProfileData(lati, long);
            SharedPred.setImage(resultProfile.imageurl!);
            myController.isProcessDone.value = 2;
            myController.processErrorMessage
                .value = resultProfile.msg!;
          } else {
            myController.isProcessDone
                .value = 0;
            myController.processErrorMessage
                .value = resultProfile.msg!;
          }
        }
      } else {
        setProfileData(lati, long);
      }
    }
  }

  Future<void> setProfileData(double lati, double long) async {
    List selecteCategorys = [];
    List feesList = [];
    List stdListSet = [];
    List aMSet = [];
    List pMSet = [];
    for (int i = 0; i < subList.length; i++) {
      if (subList[i].isSelected) {
        if (_nameController[i].text == "") {
          showSnackBar(context, "Enter price of ${subList[i].subjectName}");
          return;
        } else {
          feesList.add(_nameController[i].text);
          selecteCategorys.add(subList[i].id);
        }
      }
    }
    for (var element in stdList) {
      if (element.isSelected) {
        stdListSet.add(element.id);
      }
    }

    for (var element in hoursAvailAM) {
      if (element.isSelected) {
        aMSet.add(element.id);
      }
    }

    for (var element in hoursAvailPM) {
      if (element.isSelected) {
        pMSet.add(element.id);
      }
      }

    if(aMSet.isEmpty && pMSet.isEmpty){
      showSnackBar(context, "Please Select hours");
      return;
    }

    CustomDialog.processDialog(
      loadingMessage: "School Profile Update",
      successMessage: "School Profile Update Successfully",
    );
    if (lati == 0 && long == 0) {
     final  resultUpd = await MyServices.updateTutorProfilenoLatLong(
          mobile,
          aMSet.join(","),
          pMSet.join(","),
          username,
          selecteCategorys.join(","),
          location,
          stdListSet.join(","),
          uni,
          feesList.join(","),
          exp,
          selectedRadio.toString()).catchError(
            // ignore: body_might_complete_normally_catch_error
            (error, stackTrace) {
          myController.isProcessDone
              .value = 0;
          myController.processErrorMessage
              .value = error.toString();
        },
      );

     if (resultUpd != null) {
       if (resultUpd.status) {
         if (resultUpd.data.isEmpty) {
           SharedPred.setIsTutorReg(false);
           Get.offAll(() => const BottomNavigation());
         } else {
           SharedPred.setUsername(resultUpd.data[0].username.toString());
           SharedPred.setIsTutorReg(true);
           SharedPred.setTutorDetail(resultUpd.data);
           Get.offAll(() => const BottomNavigationTutor());
         }
       }
     }
    } else {
      final resultUpd = await MyServices.updateTutorProfile(
          mobile,
          aMSet.join(","),
          pMSet.join(","),
          username,
          selecteCategorys.join(","),
          location,
          stdListSet.join(","),
          uni,
          feesList.join(","),
          exp,
          lati.toString(),
          long.toString(),
          selectedRadio.toString()).catchError(
            // ignore: body_might_complete_normally_catch_error
            (error, stackTrace) {
          myController.isProcessDone
              .value = 0;
          myController.processErrorMessage
              .value = error.toString();
        },
      );


      if (resultUpd != null) {
        if (resultUpd.status) {
            if (resultUpd.data.isEmpty) {
              SharedPred.setIsTutorReg(false);
              Get.offAll(() => const BottomNavigation());
            } else {
              SharedPred.setUsername(resultUpd.data[0].username.toString());
              SharedPred.setIsTutorReg(true);
              SharedPred.setTutorDetail(resultUpd.data);
              Get.offAll(() => const BottomNavigationTutor());
            }
          }
        }
      }
    }
  }