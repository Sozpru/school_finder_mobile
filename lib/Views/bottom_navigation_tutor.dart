
import 'package:e_tutor/Views/request_list.dart';
import 'package:e_tutor/Views/tutor_profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../Constants/constants.dart';
import '../Constants/sharedpref.dart';
import '../Models/hours_avail_model.dart';
import '../Models/standard.dart';
import '../Models/subject_model.dart';
import '../Services/my_services.dart';
import 'my_tutor.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomNavigationTutor extends StatefulWidget {
  const BottomNavigationTutor({Key? key}) : super(key: key);

  @override
  State<BottomNavigationTutor> createState() => _BottomNavigationTutorState();
}

class _BottomNavigationTutorState extends State<BottomNavigationTutor> {
  int selectedIndex = 0;
  String? _data;

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['body'] == 'Request') {
      Get.to(
            () => const MyTutorListPage(),
      );
    }
  }

  @override
  void initState() {
    fetchSubject().then((value) {
      SharedPred.setSubjectModel(value!.data);
      fetchStd().then((value) {
        SharedPred.setStandardModel(value?.data);
        fetchHours().then((value) {
          SharedPred.setHoursModel(value?.data);
          setState(() {
            setupInteractedMessage();
            _data = "success";
          });
        });
      });
    });
    super.initState();
  }

  Future<SubjectModel?> fetchSubject() async {
    return MyServices.getSubject();
  }

  Future<HoursAvailModel?> fetchHours() async {
    return MyServices.getHoursAvailability();
  }

  Future<StandardModel?> fetchStd() async {
    return MyServices.getStandardList();
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () async {
          if (selectedIndex != 0) {
            setState(() {
                selectedIndex--;
            });
            return false;
          }
          return true;
        },
        child: Scaffold(
          body: _data == null
              ? const Center(
              child: CircularProgressIndicator(
                color: appColor,
              ))
              : IndexedStack(
            index: selectedIndex,
            children: const [
              TutorProfile(type: 1),
              RequestList(type: 1),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 6,
            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
            items:  <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: "",
                icon: Icon(
                  Icons.person,
                  size: 25.w,
                ),
              ),
              BottomNavigationBarItem(
                label: "",
                icon: Icon(
                  Icons.note_sharp,
                  size: 25.w,
                ),
              ),
            ],
            onTap: onItemTapped,
            currentIndex: selectedIndex,
            selectedItemColor: appColor,
            unselectedItemColor: const Color.fromRGBO(152, 152, 152, 1),
          ),
        ));
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
