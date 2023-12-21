import 'dart:async';
import 'package:e_tutor/Services/my_services.dart';
import 'package:e_tutor/Views/CustomWidgets/custom_dialogs.dart';
import 'package:e_tutor/Views/my_tutor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Bindings/my_bindings.dart';
import 'Constants/constants.dart';
import 'Constants/sharedpref.dart';
import 'Theme/theme_data.dart';
import 'Views/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Views/bottom_navigation_tutor.dart';
import 'Views/login_page.dart';

bool logined = false,isTutorReg = false;
String? email;


class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();

void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.input?.isNotEmpty ?? false) {
  }
}

List<String> testDeviceIds = [testDevice];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  RequestConfiguration configuration =
  RequestConfiguration(testDeviceIds: testDeviceIds);
  MobileAds.instance.updateRequestConfiguration(configuration);


  await GetStorage.init();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  email = prefs.getString("email") ?? "";
  isTutorReg = prefs.getBool("tutor_register") ?? false;
  if(email == "") {
    logined = false;
  } else {
    logined = true;
  }

  Firebase.initializeApp().whenComplete(() async {
    messaging = FirebaseMessaging.instance;

    final fcmToken = await FirebaseMessaging.instance.getToken();

    SharedPred.setToken(fcmToken!);


    if(logined){
      MyServices.updateFCM(fcmToken);
    }
    //If subscribe based on topic then use this
    await FirebaseMessaging.instance.subscribeToTopic('E-tutor');

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
          '00000', // id
          'flutter_notification_title', // title
          importance: Importance.high,
          enableLights: true,
          enableVibration: true,
          showBadge: true,
          playSound: true);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const android =
      AndroidInitializationSettings('@drawable/ic_notification');
      const iOS = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: android, iOS: iOS);

      await flutterLocalNotificationsPlugin!.initialize(initSettings,
          onDidReceiveNotificationResponse:
              (NotificationResponse notificationResponse) {
            selectNotificationStream.add(notificationResponse.payload);
          }, onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );


      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Map<String, dynamic> data = message.data;
        if (message.data["body"] == "Request") {
          CustomDialog.notificationDilog(navigatorKey.currentState!.context,data['title'],data['notification_name']);
        }

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
          if (message.data["body"] == "Request") {
            Navigator.push(
                navigatorKey.currentState!.context,
                MaterialPageRoute(
                    builder: (context) => const MyTutorListPage()));
          }
        });

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        // If `onMessage` is triggered with a notification, construct our own
        // local notification to show to users using the created channel.
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin?.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel!.id,
                  channel!.name,
                  icon: android.smallIcon,
                  // other properties...
                ),
              ));
        }
      });
    }
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, widget) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialBinding: MyBindings(),
        themeMode: ThemeMode.light,
        title: 'School Finder',
        navigatorKey: navigatorKey,
        home:getWid(),
      ),
    );
  }

  Widget? getWid(){
    if(!logined){
      return const LoginPage();
    }else if(logined && isTutorReg){
      return const BottomNavigationTutor();
    }else{
      return const BottomNavigation();
    }
  }
}
