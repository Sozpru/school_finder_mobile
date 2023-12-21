import 'dart:convert';

import 'package:e_tutor/Models/tutor_detail_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/hours_avail_model.dart';
import '../Models/standard.dart';
import '../Models/subject_model.dart';

class SharedPred {
  static void setHoursModel(List<HoursAvailData>? stdModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('hrsModel', json.encode(stdModel));
  }

  static Future<String?> getHoursModel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('hrsModel');
  }

  static void setSubjectModel(List<SubjectDataModel>? stdModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('subModel', json.encode(stdModel));
  }

  static Future<String?> getSubjectModel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('subModel');
  }

  static void setStandardModel(List<StandardDataModel>? stdModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('stdModel', json.encode(stdModel));
  }

  static Future<String?> getStandardModel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('stdModel');
  }

  static void setTutorDetail(List<Data> tutorDetail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tutorDetail', json.encode(tutorDetail));
  }

  static Future<String?> getTutorDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tutorDetail');
  }

  static void setEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  static Future getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? "";
  }
  static void setFBSUCESS(bool email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('FBSUCESS', email);
  }

  static Future getFBSUCESS() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('FBSUCESS') ?? false;
  }

  static void setImage(String image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('image', image);
  }

  static Future getImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('image') ?? "";
  }

  static void setUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? "";
  }

  static void setMobile(String mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobile', mobile);
  }

  static Future getMobile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('mobile') ?? "";
  }

  static void setStd(String std) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('std', std);
  }

  static Future getStd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('std') ?? "";
  }

  static void setTutorRating(String std,String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('rating$email', std);
  }

  static Future getTutorRating(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('rating$email') ?? "";
  }

  static void setLoc(String loc) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('loc', loc);
  }

  static Future getLoc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('loc') ?? "";
  }

  static void setToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }

  static void setIsStudent(bool isStudent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('IsStudent', isStudent);
  }

  static Future<bool?> getIsStudent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('IsStudent') ?? false;
  }

  static void setIsTutorReg(bool tutorRegister) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutor_register', tutorRegister);
  }

  static Future<bool?> getIsTutorReg() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutor_register') ?? false;
  }

  static void setloginWith(int loginWith) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loginWith', loginWith);
  }

  static Future<int?> getloginWith() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('loginWith') ?? 0;
  }
}
