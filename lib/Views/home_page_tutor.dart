import 'dart:convert';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Models/standard.dart';
import 'package:e_tutor/Models/tutor_detail_model.dart';
import 'package:e_tutor/Views/CustomWidgets/custom_dialogs.dart';
import 'package:e_tutor/Views/bottom_navigation_tutor.dart';
import 'package:e_tutor/Views/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../Constants/constants.dart';
import '../Helper/helper.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/subject_model.dart';
import '../Services/my_services.dart';
import 'CustomDrawer/custom_tutor_drawer.dart';
import 'CustomWidgets/custom_text_form_field.dart';
import 'CustomWidgets/handle_errors_page.dart';
import 'CustomWidgets/multi_select.dart';
import 'CustomWidgets/show_snackbar.dart';
import 'bottom_navigation.dart';

class HomePageTutor extends StatefulWidget {
  const HomePageTutor({Key? key}) : super(key: key);

  @override
  State<HomePageTutor> createState() => _HomePageTutorState();
}

class _HomePageTutorState extends State<HomePageTutor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<SubjectModel?>? subjectData;
  List<SubjectDataModel> subjectDataAdd = [];
  List<StandardDataModel> standardData = [];
  String subjectList = "";
  final List<TextEditingController> _nameController = [];
  final formKey = GlobalKey<FormState>();
  List<String> flavours = [];

  var colors = [
    const Color.fromRGBO(239, 162, 137, 1),
    const Color.fromRGBO(136, 209, 240, 1),
    const Color.fromRGBO(179, 154, 229, 1),
  ];

  var colorsIcon = [
    const Color.fromRGBO(208, 95, 58, 1),
    const Color.fromRGBO(74, 169, 209, 1),
    const Color.fromRGBO(142, 131, 213, 1.0),
  ];

  int selectedRadio = 1;
  String? _data;
  // ignore: prefer_typing_uninitialized_variables
  var long, lat;
  Position? aa;
  List<String> subName = [];
  String uni = "", yearOfExp = "", location = "";

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  void initState() {
    fetchSubject(false);
    super.initState();
  }

  fetchIntData() {
    SharedPred.getStandardModel().then((value) {
      standardData = (json.decode(value!) as List)
          .map((data) => StandardDataModel.fromJson(data))
          .toList();
      for (var element in standardData) {
        myController.options.add("Standard ${element.std!}");
        setState(() {
          _data = "success";
        });
      }
    });
  }

  fetchSubject(bool istry) async {
    subjectData = MyServices.getSubject();
    if (!istry) {
      fetchIntData();
    } else {
      setState(() {
        _data = "success";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, //or set color with: Color(0xFF0000FF)
    ));

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "School Finder",
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: const Color.fromRGBO(57, 57, 57, 1)),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.notes_rounded,
                color: appColor,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: <Widget>[
            Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      Get.to(() => const NotificationPage());
                    },
                    icon: const Icon(
                      Icons.notifications,
                      color: appColor,
                    )))
          ],
        ),
        drawer: const CustomDrawerTutor(),
        body: _data == null
            ? const CircularProgressIndicator()
            : AnnotatedRegion(
                value: const SystemUiOverlayStyle(statusBarColor: appColor),
                child: ListView(children: <Widget>[
                  const SBH10(),
                  Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: SizedBox(
                          height: 100,
                          child: FutureBuilder<SubjectModel?>(
                              future: subjectData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CPI();
                                } else if (snapshot.hasError) {
                                  return HandleErrorsPage(
                                    errorType: snapshot.error.toString(),
                                    tryAgain: () {
                                      setState(() {
                                        fetchSubject(true);
                                      });
                                    },
                                  );
                                } else if (!snapshot.data!.status) {
                                  return HandleErrorsPage(
                                    errorType: snapshot.data!.msg,
                                  );
                                } else {
                                  final data = snapshot.data!.data;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                          onTap: () {
                                            var distIdsCh =
                                                subName.toSet().toList();
                                            if (distIdsCh.length > 2 &&
                                                !data[index].isSelected) {
                                              showSnackBar(context,
                                                  'Maximum 3 subject selection are allowed');
                                            } else {
                                              data[index].isSelected
                                                  ? subName
                                                      .remove(data[index].id!)
                                                  : subName
                                                      .add(data[index].id!);
                                              data[index].isSelected =
                                                  !data[index].isSelected;
                                              var distIds =
                                                  subName.toSet().toList();
                                              subjectList = distIds.join(",");
                                              setState(() {
                                                if (data[index].isSelected) {
                                                  subjectDataAdd
                                                      .add(data[index]);
                                                  _nameController.add(
                                                      TextEditingController());
                                                } else {
                                                  for (int i = 0;
                                                      i < subjectDataAdd.length;
                                                      i++) {
                                                    if (subjectDataAdd[i] ==
                                                        data[index]) {
                                                      subjectDataAdd
                                                          .remove(data[index]);
                                                      _nameController
                                                          .removeAt(i);
                                                    }
                                                  }
                                                }
                                              });
                                            }
                                          },
                                          child: SizedBox(
                                              height: 100,
                                              width: 150,
                                              child: Card(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0)),
                                                  margin: const EdgeInsets.only(
                                                      left: 10, right: 10),
                                                  elevation: 0,
                                                  color: colors[index % 3],
                                                  child: Column(children: [
                                                    Visibility(
                                                        maintainSize: true,
                                                        maintainAnimation: true,
                                                        maintainState: true,
                                                        visible: data[index]
                                                            .isSelected,
                                                        child: Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(7),
                                                                child: ClipOval(
                                                                  child:
                                                                      Material(
                                                                    color: colorsIcon[
                                                                        index %
                                                                            3],
                                                                    // Button color
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {},
                                                                      child: const SizedBox(
                                                                          width: 16,
                                                                          height: 16,
                                                                          child: Icon(
                                                                            Icons.check,
                                                                            size:
                                                                                10.17,
                                                                            color:
                                                                                Colors.white,
                                                                          )),
                                                                    ),
                                                                  ),
                                                                )))),
                                                    Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.network(
                                                              data[index]
                                                                  .image!,
                                                              // color:
                                                              //     colors_icon[
                                                              //         index %
                                                              //             3],
                                                              width: 30,
                                                              height: 30,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  Image.asset(
                                                                    'assets/Images/ic_placeholder.png',
                                                                    width: 30,
                                                                  )),
                                                          // Container(height: 30,
                                                          //     // color: colors_icon[index % 3],
                                                          //     width: 30,decoration: BoxDecoration(
                                                          //     borderRadius : BorderRadius.circular(10),image : DecorationImage(image: NetworkImage(data[index].image!),
                                                          // ))),
                                                          const SBH5(),
                                                          Text(
                                                              data[index]
                                                                  .subjectName!,maxLines: 1,overflow: TextOverflow.ellipsis,
                                                              style: GoogleFonts.roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .white))
                                                        ])
                                                  ]))));
                                    },
                                  );
                                }
                              }))),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, bottom: 10, top: 10),
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 20, 15),
                          //extra 10 for top padding because triangle's height = 10
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(238, 239, 248, 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(children: [
                            const SBH5(),
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text('School Registration',
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: const Color.fromRGBO(
                                            57, 57, 57, 1)))),
                            const SBH10(),
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 5, left: 5, right: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white),
                                  child: DropDownMultiSelect(
                                    onChanged: (value) {
                                      myController.select.value = value;
                                      myController.selOpt.value = "";
                                      for (var element in myController.select.value) {
                                        myController.selOpt.value =
                                            "${myController.selOpt.value} , $element";
                                      }
                                    },
                                    hintStyle: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        color: const Color.fromRGBO(98, 98, 98, 1),
                                        fontSize: 15),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: appColor,
                                    ),
                                    options: myController.options,
                                    selectedValues: myController.select.value,
                                    whenEmpty: 'Select Standard',
                                  ),
                                )),
                            subjectDataAdd.isEmpty
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 10),
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        itemCount: subjectDataAdd.length,
                                        itemBuilder: (context, index) {
                                          var title = subjectDataAdd[index]
                                              .subjectName;
                                          return Row(
                                            children: [
                                              Expanded(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10,
                                                              bottom: 10),
                                                      child: Container(
                                                          height: 44,
                                                          width: 147,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Padding(
                                                                      padding: const EdgeInsets.only(left: 15),
                                                                      child: Text(title!,
                                                                          style: GoogleFonts.roboto(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: const Color.fromRGBO(
                                                                                98,
                                                                                98,
                                                                                98,
                                                                                1),
                                                                          )))))))),
                                              Expanded(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              bottom: 10),
                                                      child: Container(
                                                          height: 44,
                                                          width: 147,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 5),
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: TextFormField(
                                                                      controller: _nameController[index],
                                                                      keyboardType: TextInputType.number,
                                                                      decoration: const InputDecoration(hintStyle : TextStyle(color: appgreyHomeText),hintText : "Price",border: InputBorder.none),
                                                                      style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        color: const Color.fromRGBO(
                                                                            98,
                                                                            98,
                                                                            98,
                                                                            1),
                                                                      )))))))
                                            ],
                                          );
                                        })),
                            Form(
                                key: formKey,
                                child: Column(children: [
                                  const SBH5(),
                                  TFF(
                                    color: Colors.white,
                                    align: TextAlign.left,
                                    hintText: "Enter University",
                                    keyboardType: TextInputType.text,
                                    onSaved: (data) {
                                      uni = data!.trim();
                                    },
                                  ),
                                  const SBH10(),
                                  TFF(
                                    color: Colors.white,
                                    align: TextAlign.left,
                                    hintText: "Enter Address",
                                    keyboardType: TextInputType.text,
                                    onSaved: (data) {
                                      location = data!.trim();
                                    },
                                  ),
                                  const SBH10(),
                                  TFF(
                                    color: Colors.white,
                                    align: TextAlign.left,
                                    hintText: "Year of Experience",
                                    keyboardType: TextInputType.number,
                                    onSaved: (data) {
                                      yearOfExp = data!.trim();
                                    },
                                  ),
                                  const SBH10(),
                                ])),
                            Column(
                              children: [
                                const SBH5(),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text('Tution type',
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 17,
                                            color: const Color.fromRGBO(
                                                98, 98, 98, 1)))),
                                Row(children: [
                                  Expanded(
                                      child: ListTile(
                                          title: Transform.translate(
                                            offset: const Offset(-25, 0),
                                            child: Text("Online",
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color.fromRGBO(
                                                        98, 98, 98, 1))),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          leading: Radio(
                                            value: 1,
                                            groupValue: selectedRadio,
                                            activeColor: appColor,
                                            onChanged: (val) {
                                              setSelectedRadio(val!);
                                            },
                                          ))),
                                  Expanded(
                                      child: ListTile(
                                          title: Transform.translate(
                                            offset: const Offset(-25, 0),
                                            child: Text("Offline",
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color.fromRGBO(
                                                        98, 98, 98, 1))),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          leading: Radio(
                                            value: 2,
                                            groupValue: selectedRadio,
                                            activeColor: appColor,
                                            onChanged: (val) {
                                              setSelectedRadio(val!);
                                            },
                                          ))),
                                  Expanded(
                                      child: ListTile(
                                          title: Transform.translate(
                                            offset: const Offset(-25, 0),
                                            child: Text("Both",
                                                style: GoogleFonts.roboto(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color.fromRGBO(
                                                        98, 98, 98, 1))),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          leading: Radio(
                                            value: 3,
                                            groupValue: selectedRadio,
                                            activeColor: appColor,
                                            onChanged: (val) {
                                              setSelectedRadio(val!);
                                            },
                                          ))),
                                ]),
                                const SBH20(),
                                const SBH20(),
                                const SBH20(),
                                const SBH20(),
                                SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: appYellowButton,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500)),
                                      onPressed: () async {
                                        formKey.currentState!.save();
                                        if (subjectList == "") {
                                          showSnackBar(
                                              context, "Select Subject");
                                          return;
                                        }
                                        List<String> mnthlyFees = [];
                                        for (int i = 0;
                                            i < _nameController.length;
                                            i++) {
                                          if (_nameController[i].text == "") {
                                            showSnackBar(context,
                                                "Enter Fees of ${subjectDataAdd[i].subjectName}");
                                            return;
                                          } else {
                                            mnthlyFees
                                                .add(_nameController[i].text);
                                          }
                                        }
                                        List<String> lss = [];
                                        if (myController.select.value.isEmpty) {
                                          showSnackBar(
                                              context, "Select standard");
                                          return;
                                        } else {
                                          for (var element in myController.select.value) {
                                            var remove = element.replaceAll(
                                                "Standard ", "");
                                            for (var element in standardData) {
                                              if (element.std == remove) {
                                                lss.add(element.id!);
                                              }
                                            }
                                          }
                                        }
                                        callUpdateApi(
                                            selectedRadio.toString(),
                                            lss.join(","),
                                            uni,
                                            yearOfExp,
                                            subjectList,
                                            location,
                                            mnthlyFees.join(","));
                                      },
                                      child: const Text(
                                        "Register",
                                      ),
                                    )),
                              ],
                            )
                          ])))
                ])));
  }

  Future<void> callUpdateApi(String tutionType, String std, String uni,
      String exp, String sub, String loc, String monthFees) async {
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

    CustomDialog.processDialog(
      loadingMessage: "School Registration",
      successMessage: "School Registration Successfully",
    );
    final TutorDetailModel? resultUpd;
    if (lati == 0 && long == 0) {
      resultUpd = await MyServices.updateTutornoLatLong(
              sub, loc, std, uni, monthFees, exp, tutionType)
          .catchError(
        // ignore: body_might_complete_normally_catch_error
        (error, stackTrace) {
          myController.isProcessDone.value = 0;
          myController.processErrorMessage.value = error.toString();
        },
      );
    } else {
      resultUpd = await MyServices.updateTutorProfilenoUsername(
              sub,
              loc,
              std,
              uni,
              monthFees,
              exp,
              lati.toString(),
              long.toString(),
              tutionType)
          .catchError(
        // ignore: body_might_complete_normally_catch_error
        (error, stackTrace) {
          myController.isProcessDone.value = 0;
          myController.processErrorMessage.value = error.toString();
        },
      );
    }

    if (resultUpd != null) {
      if (resultUpd.status) {
        myController.isProcessDone.value = 3;
        myController.processErrorMessage.value = resultUpd.msg;
        if (resultUpd.data.isEmpty) {
          SharedPred.setIsTutorReg(false);
          SharedPred.setTutorDetail([]);
          Get.offAll(() => const BottomNavigation());
        } else {
          SharedPred.setIsTutorReg(true);
          SharedPred.setTutorDetail(resultUpd.data);
          Get.offAll(() => const BottomNavigationTutor());
        }
      } else {
        myController.isProcessDone.value = 0;
        myController.processErrorMessage.value = resultUpd.msg;
      }
    }
  }
}

