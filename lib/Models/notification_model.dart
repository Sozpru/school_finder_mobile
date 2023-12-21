import 'dart:convert';

NotificationModel itemStockModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

class NotificationModel {
  NotificationModel({
    required this.status,
    this.data,
    this.reqData,
    required this.msg,
  });

  bool status;
  List<DataModel>? data;
  List<RequestModel>? reqData;
  String msg;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<DataModel>.from(
                json["data"].map((x) => DataModel.fromJson(x))),
        reqData: json["request"] == null
            ? []
            : List<RequestModel>.from(
                json["request"].map((x) => RequestModel.fromJson(x))),
        msg: json["msg"],
      );
}

class DataModel {
  DataModel({
    required this.id,
    required this.title,
    required this.message,
    required this.userId,
    required this.type,
  });

  String id;
  String title;
  bool expanded = false;
  String message;
  String userId;
  String type;

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        userId: json["user_id"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "message": message,
        "user_id": userId,
        "type": type,
      };
}

class RequestModel {
  RequestModel({
    required this.id,
    required this.tutorEmail,
    required this.sname,
    required this.username,
  });

  String id;
  String tutorEmail;
  bool expanded = false;
  String sname;
  String username;

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: json["id"],
        tutorEmail: json["tutor_email"],
        sname: json["sname"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sname": sname,
        "tutor_email": tutorEmail,
        "username": username,
      };
}
