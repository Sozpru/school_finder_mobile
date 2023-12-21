
import 'dart:convert';

TutorModel itemStockModelFromJson(String str) =>
    TutorModel.fromJson(json.decode(str));

class TutorModel {
  TutorModel({
    required this.status,
    this.data,
    required this.msg,
  });

  bool status;
  List<TutorDataModel>? data;
  String msg;

  factory TutorModel.fromJson(Map<String, dynamic> json) => TutorModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<TutorDataModel>.from(
                json["data"].map((x) => TutorDataModel.fromJson(x))),
        msg: json["msg"],
      );
}

class TutorDataModel {
  TutorDataModel({
    required this.id,
    required this.distance,
    required this.email,
    required this.tutorEmail,
    required this.standard,
    required this.subject,
    required this.monthlyFees,
    required this.university,
    required this.location,
    required this.yearOfExperience,
    required this.mobileNo,
    required this.datetime,
    required this.latitude,
    required this.longitude,
    required this.tuitionType,
    required this.mHours,
    required this.aHours,
    required this.username,
    required this.image,
    required this.firebaseId,
    required this.fcmToken,
    required this.regDate,
    required this.userType,
    required this.type,
    required this.sname,
    required this.rating,
    required this.status,
    required this.fees,
  });

  String? status;
  String? id;
  String? email;
  String? tutorEmail;
  String? standard;
  String? sname;
  String? rating;
  String? distance;
  String? subject;
  String? monthlyFees;
  String? university;
  String? location;
  String? yearOfExperience;
  String? mobileNo;
  String? datetime;
  String? latitude;
  String? longitude;
  String? tuitionType;
  String? mHours;
  String? aHours;
  String? username;
  String? image;
  String? firebaseId;
  String? fcmToken;
  String? regDate;
  String? userType;
  String? type;
  String? fees;

  factory TutorDataModel.fromJson(Map<String, dynamic> json) => TutorDataModel(
        fees: json["fees"] ?? "",
        status: json["status"] ?? "",
        distance: json["distance"] ?? "",
        sname: json["sname"] ?? "",
        rating: json["rating"] ?? "",
        id: json["id"] ?? "",
        tutorEmail: json["tutor_email"] ?? "",
        email: json["email"] ?? "",
        standard: json["standard"] ?? "",
        subject: json["subject"] ?? "",
        monthlyFees: json["monthly_fees"] ?? "",
        university: json["university"] ?? "",
        location: json["location"] ?? "",
        yearOfExperience: json["year_of_experience"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        datetime: json["datetime"] ?? "",
        latitude: json["latitude"] ?? "",
        longitude: json["longitude"] ?? "",
        tuitionType: json["tuition_type"] ?? "",
        mHours: json["m_hours"] ?? "",
        aHours: json["a_hours"] ?? "",
        username: json["username"] ?? "",
        image: json["image"] ?? "",
        firebaseId: json["firebase_id"] ?? "",
        fcmToken: json["fcm_token"] ?? "",
        regDate: json["reg_date"] ?? "",
        userType: json["user_type"] ?? "",
        type: json["type"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "fees": fees,
        "distance": distance,
        "id": id,
        "status": status,
        "email": email,
        "tutor_email": tutorEmail,
        "standard": standard,
        "subject": subject,
        "monthly_fees": monthlyFees,
        "university": university,
        "location": location,
        "year_of_experience": yearOfExperience,
        "mobile_no": mobileNo,
        "datetime": datetime,
        "latitude": latitude,
        "longitude": longitude,
        "tuition_type": tuitionType,
        "m_hours": mHours,
        "a_hours": aHours,
        "username": username,
        "image": image,
        "firebase_id": firebaseId,
        "fcm_token": fcmToken,
        "reg_date": regDate,
        "user_type": userType,
        "type": type,
        "sname": sname,
        "rating": rating,
      };
}
