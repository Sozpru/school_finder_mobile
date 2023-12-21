import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:e_tutor/Models/my_student_model.dart';
import 'package:e_tutor/Models/notification_model.dart';
import 'package:e_tutor/Models/tutor_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import '../Askme/get_ask_me_model.dart';
import '../Constants/constants.dart';
import '../Models/about_privacy_model.dart';
import '../Models/hours_avail_model.dart';
import '../Models/login_model.dart';
import '../Models/my_tutor_model.dart';
import '../Models/standard.dart';
import '../Models/stripe_payment_detail.dart';
import '../Models/student_model.dart';
import '../Models/subject_model.dart';
import '../Models/success_img.dart';
import '../Models/successdata.dart';
import '../Models/tutor_detail_model.dart';

class MyServices {
  static Dio dio = Dio();

  static String url = "http://192.168.1.18:8000/";


  static Future<dynamic> handleErrors(e) {
    if (e.type == DioErrorType.response) {
      return Future.error("Something went wrong");
    } else if (e.type == DioErrorType.receiveTimeout) {
      return Future.error("Took longer to load !");
    } else if (e.type == DioErrorType.other) {
      if (e.message.contains('SocketException')) {
        return Future.error("No Internet Connection");
      } else {
        return Future.error("Something went wrong");
      }
    } else {
      return Future.error("Something went wrong");
    }
  }

  static Future<Success?> setAskMeQuestion(String que,String ans) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "set_ask_me_questions",
          "email": await getemail(),
          "question": que,
          "answer": ans,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'set_ask_me_questions', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<AskMeGetModel?> getAskMeQuestion() async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "get_ask_me_questions",
          "email": await getemail(),
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'get_ask_me_questions', email: await getemail()),
          ),
        ),
      );
      return AskMeGetModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<PaymentDetail?> getPayementDetail(String email) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "get_payment_details",
          "email": await getemail(),
          "tutor_email": email
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'get_payment_details', email: await getemail()),
          ),
        ),
      );
      return PaymentDetail.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Success?> setPayementDetail(
      String email, String transId) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "set_payment_details",
          "email": await getemail(),
          "tutor_email": email,
          "transaction_id": transId
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'set_payment_details', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Success?> sendFeesRequest(String email) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "send_payment_request",
          "email": await getemail(),
          "student_email": email
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'send_payment_request', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Success?> addRating(String rate, String email) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "add_rating",
          "email": await getemail(),
          "rate": rate,
          "tutor_email": email
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: 'add_rating', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<String> getemail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? "";
  }

  static Future<String> getType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool stt = prefs.getBool('IsStudent') ?? false;
    return stt ? "student" : "tutor";
  }

  static Future<TutorDetailModel?> getTutorDetil() async {
    try {
      var response = await dio.post(
        url,
        data: {"name": "get_tutor_details", "email": await getemail()},
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'get_tutor_details', email: await getemail()),
          ),
        ),
      );
      return TutorDetailModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<SuccessImg?> addStudentTutorProfileImg(
      CroppedFile img, String apiName) async {
    String fileName = img.path.split('/').last;
    FormData formData1 = FormData.fromMap({
      "name": apiName,
      "email": await getemail(),
      "image": await MultipartFile.fromFile(img.path,
          filename: fileName,
          contentType: MediaType('image', fileName.split(".").last)),
      "type": "image/${fileName.split(".").last}"
    });

    try {
      var response = await dio.post(
        url,
        data: formData1,
        options: Options(
          headers: getHeader(
            token: getHashToken(name: apiName, email: await getemail()),
          ),
        ),
      );
      return SuccessImg.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Success?> updateFCM(String token) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "update_fcm_token",
          "email": await getemail(),
          "type": await getType(),
          "fcm_token": token,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token:
                getHashToken(name: 'update_fcm_token', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Success?> updateStudentProfile(
      String username, String location, String mobile, String std) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "student_registration",
          "email": await getemail(),
          "username": username,
          "location": location,
          "mobile_no": mobile,
          "standard": std
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'student_registration', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Success?> reqAcceptDelete(
    String studentEmail,
    String status,
  ) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "request_status",
          "email": await getemail(),
          "student_email": studentEmail,
          "status": status,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token:
                getHashToken(name: 'request_status', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorDetailModel?> updateTutornoLatLong(
      String sub, String loc,String  std,String  uni,String  monthFees,String  exp,String  tutionType) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "tutor_registration",
          "email": await getemail(),
          "subject": sub,
          "location": loc,
          "university": uni,
          "standard": std,
          "monthly_fees": monthFees,
          "year_of_experience": exp,
          "tuition_type": tutionType,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'tutor_registration', email: await getemail()),
          ),
        ),
      );
      return TutorDetailModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorDetailModel?> updateTutorProfilenoLatLong(
      String mobileNo,
      String mHours,
      String aHours,
      String username,
      String subject,
      String location,
      String std,
      String university,
      String monthlyFees,
      String yearOfExperience,
      String tuitionType) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "tutor_registration",
          "email": await getemail(),
          "mobile_no": mobileNo,
          "m_hours": mHours,
          "a_hours": aHours,
          "subject": subject,
          "username": username,
          "location": location,
          "university": university,
          "standard": std,
          "monthly_fees": monthlyFees,
          "year_of_experience": yearOfExperience,
          "tuition_type": tuitionType,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'tutor_registration', email: await getemail()),
          ),
        ),
      );
      return TutorDetailModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorDetailModel?> updateTutorProfilenoUsername(
      String subject,
      String location,
      String std,
      String university,
      String monthlyFees,
      String yearOfExperience,
      String latitude,
      String longitude,
      String tuitionType) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "tutor_registration",
          "email": await getemail(),
          "subject": subject,
          "location": location,
          "university": university,
          "standard": std,
          "monthly_fees": monthlyFees,
          "year_of_experience": yearOfExperience,
          "latitude": latitude,
          "longitude": longitude,
          "tuition_type": tuitionType,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'tutor_registration', email: await getemail()),
          ),
        ),
      );
      return TutorDetailModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorDetailModel?> updateTutorProfile(
      String mobileNo,
      String mHours,
      String aHours,
      String username,
      String subject,
      String location,
      String std,
      String university,
      String monthlyFees,
      String yearOfExperience,
      String latitude,
      String longitude,
      String tuitionType) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "tutor_registration",
          "email": await getemail(),
          "subject": subject,
          "mobile_no": mobileNo,
          "m_hours": mHours,
          "a_hours": aHours,
          "location": location,
          "username": username,
          "university": university,
          "standard": std,
          "monthly_fees": monthlyFees,
          "year_of_experience": yearOfExperience,
          "latitude": latitude,
          "longitude": longitude,
          "tuition_type": tuitionType,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'tutor_registration', email: await getemail()),
          ),
        ),
      );
      return TutorDetailModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Success?> sendRequest(String tutoerEmail, String subject,
      String fees, String mHours, String aHours, String tuitionType) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "send_request",
          "email": await getemail(),
          "tutor_email": tutoerEmail,
          "subject": subject,
          "fees": fees,
          "m_hours": mHours,
          "a_hours": aHours,
          "tuition_type": tuitionType,
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: 'send_request', email: await getemail()),
          ),
        ),
      );
      return Success.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<NotificationModel?> getNotificationList() async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "notification_list",
          "email": await getemail(),
          "type": await getType()
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'notification_list', email: await getemail()),
          ),
        ),
      );

      return NotificationModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<Student?> getMyStudentList(String apiName) async {
    try {
      var response = await dio.post(
        url,
        data: {"name": apiName, "email": await getemail()},
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: apiName, email: await getemail()),
          ),
        ),
      );

      return Student.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorModel?> getTutorListNearby(
      {required String lat, required String long}) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "nearby_tutor",
          "email": await getemail(),
          "latitude": lat,
          "longitude": long
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: 'nearby_tutor', email: await getemail()),
          ),
        ),
      );
      return TutorModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<AboutPrivacyModel?> getAboutAndPrivacy() async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "setting",
          "email": await getemail(),
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: 'setting', email: await getemail()),
          ),
        ),
      );
      return AboutPrivacyModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<SubjectModel?>? getSubject() async {
    try {
      var response = await dio.post(
        url,
        data: {"name": "subject", "email": await getemail()},
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: 'subject', email: await getemail()),
          ),
        ),
      );

      return SubjectModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<HoursAvailModel?>? getHoursAvailability() async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "get_hours_availability",
          "email": await getemail(),
        },
        options: Options(
          headers: getHeader(
            token: getHashToken(
                name: 'get_hours_availability', email: await getemail()),
          ),
        ),
      );
      return HoursAvailModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorDetailModel?>? getTutorDetail(String email) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "get_particular_tutor_details",
          "email": await getemail(),
          "tutor_email": email
        },
        options: Options(
          headers: getHeader(
            token: getHashToken(
                name: 'get_particular_tutor_details', email: await getemail()),
          ),
        ),
      );

      return TutorDetailModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorModel?> getTutorBySubject(String subject) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "home_subject_tutor",
          "email": await getemail(),
          "subject": subject
        },
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(
                name: 'home_subject_tutor', email: await getemail()),
          ),
        ),
      );
      return TutorModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<StandardModel?> getStandardList() async {
    try {
      var response = await dio.post(
        url,
        data: {"name": "standard", "email": await getemail()},
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: 'standard', email: await getemail()),
          ),
        ),
      );

      return StandardModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<TutorModel?> getTutorList(String apiName) async {
    try {
      var response = await dio.post(
        url,
        data: {"name": apiName, "email": await getemail()},
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: apiName, email: await getemail()),
          ),
        ),
      );

      return TutorModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<MyTutorModel?> getMyTutorList(String apiName) async {
    try {
      var response = await dio.post(
        url,
        data: {"name": apiName, "email": await getemail()},
        options: Options(
          // receiveTimeout: 5000,
          headers: getHeader(
            token: getHashToken(name: apiName, email: await getemail()),
          ),
        ),
      );
      return MyTutorModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<LoginModel?> loginUserWithPassword(
      {required String username,
      required String email,
      required String userType,
      required String type,
      required String fcmToken,
      required String password}) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "login",
          "username": username,
          "email": email,
          "user_type": userType,
          "type": type,
          "fcm_token": fcmToken,
          "password": password
        },
        options: Options(
          headers: getHeader(
            token: getHashToken(name: 'login', email: email),
          ),
        ),
      );
      return LoginModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<LoginModel?> forgotPassword(
      {required String email,
      required String type,
      required String password}) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "forgot_password",
          "email": email,
          "type": type,
          "password": password,
        },
        options: Options(
          headers: getHeader(
            token: getHashToken(name: 'forgot_password', email: email),
          ),
        ),
      );
      return LoginModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<StudentModel?> studentDetail(String email) async {
    try {
      final response = await dio.post(
        url,
        data: {
          "name": "get_student_details",
          "email": email,
        },
        options: Options(
          headers: getHeader(
            token: getHashToken(name: 'get_student_details', email: email),
          ),
        ),
      );
      return StudentModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<LoginModel?> loginUser(
      {required String username,
      required String email,
      required String userType,
      required String type,
      required String fcmToken}) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "login",
          "username": username,
          "email": email,
          "user_type": userType,
          "type": type,
          "fcm_token": fcmToken
        },
        options: Options(
          headers: getHeader(
            token: getHashToken(name: 'login', email: email),
          ),
        ),
      );
      return LoginModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Future<LoginModel?> loginUserWithoutusername(
      {required String email,
      required String userType,
      required String type,
      required String fcmToken}) async {
    try {
      var response = await dio.post(
        url,
        data: {
          "name": "login",
          "email": email,
          "user_type": userType,
          "type": type,
          "fcm_token": fcmToken
        },
        options: Options(
          headers: getHeader(
            token: getHashToken(name: 'login', email: email),
          ),
        ),
      );
      return LoginModel.fromJson(jsonDecode(response.data));
    } on DioError catch (e) {
      return await handleErrors(e);
    }
  }

  static Map<String, String> getHeader({required String token}) {
    var headers = {"Content-Type": "application/json", "token": token};
    return headers;
  }
}
