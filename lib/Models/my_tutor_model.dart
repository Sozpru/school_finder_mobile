// To parse this JSON data, do
//
//     final itemStockModel = itemStockModelFromJson(jsonString);

import 'dart:convert';

MyTutorModel itemStockModelFromJson(String str) =>
    MyTutorModel.fromJson(json.decode(str));

class MyTutorModel {
  MyTutorModel({
    required this.status,
    this.data,
    required this.msg,
  });

  bool status;
  List<MyTutorDataModel>? data;
  String msg;

  factory MyTutorModel.fromJson(Map<String, dynamic> json) => MyTutorModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<MyTutorDataModel>.from(
                json["data"].map((x) => MyTutorDataModel.fromJson(x))),
        msg: json["msg"],
      );

// Map<String, dynamic> toJson() => {
//   "status": status,
//   "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   "msg": msg,
// };
}

class MyTutorDataModel {
  MyTutorDataModel({
    required this.id,
    required this.distance,
    required this.studentEmail,
    required this.tutorEmail,
    required this.subject,
    required this.fees,
    required this.status,
    required this.mHours,
    required this.aHours,
    required this.username,
    required this.tuitionType,
    required this.image,
    required this.transactionId,
    required this.amount,
    required this.datetime,
    required this.sname,
    required this.location,
    required this.mobileNo,
    required this.stdName,
  });

  String? id;
  String? distance;
  String? studentEmail;
  String? tutorEmail;
  String? subject;
  String? fees;
  String? status;
  String? mHours;
  String? aHours;
  String? username;
  String? tuitionType;
  String? image;
  String? transactionId;
  String? amount;
  String? datetime;
  String? sname;
  String? location;
  String? mobileNo;
  String? stdName;

  factory MyTutorDataModel.fromJson(Map<String, dynamic> json) =>
      MyTutorDataModel(
        id: json["id"] ?? "",
        distance: json["distance"] ?? "",
        tutorEmail: json["tutor_email"] ?? "",
        studentEmail: json["student_email"] ?? "",
        subject: json["subject"] ?? "",
        fees: json["fees"] ?? "",
        status: json["status"] ?? "",
        mHours: json["m_hours"] ?? "",
        aHours: json["a_hours"] ?? "",
        username: json["username"] ?? "",
        tuitionType: json["tuition_type"] ?? "",
        image: json["image"] ?? "",
        transactionId: json["transaction_id"] ?? "",
        amount: json["amount"] ?? "",
        datetime: json["datetime"] ?? "",
        sname: json["sname"] ?? "",
        location: json["location"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        stdName: json["std_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "distance": distance,
        "tutor_email": tutorEmail,
        "student_email": studentEmail,
        "subject": subject,
        "fees": fees,
        "status": status,
        "m_hours": mHours,
        "a_hours": aHours,
        "username": username,
        "tuition_type": tuitionType,
        "image": image,
        "transaction_id": transactionId,
        "amount": amount,
        "datetime": datetime,
        "sname": sname,
        "location": location,
        "mobile_no": mobileNo,
        "std_name": stdName,
      };
}
