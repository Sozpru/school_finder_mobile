import 'dart:convert';

HoursAvailModel itemStockModelFromJson(String str) =>
    HoursAvailModel.fromJson(json.decode(str));

class HoursAvailModel {
  HoursAvailModel({
    required this.status,
    this.data,
    required this.msg,
  });

  bool status;
  List<HoursAvailData>? data;
  String msg;

  factory HoursAvailModel.fromJson(Map<String, dynamic> json) =>
      HoursAvailModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<HoursAvailData>.from(
                json["data"].map((x) => HoursAvailData.fromJson(x))),
        msg: json["msg"],
      );

// Map<String, dynamic> toJson() => {
//   "status": status,
//   "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   "msg": msg,
// };
}

class HoursAvailData {
  HoursAvailData(
      {required this.id, required this.hours, required this.session});

  String? id;
  String? hours;
  String? session;
  bool isSelected = false;

  factory HoursAvailData.fromJson(Map<String, dynamic> json) => HoursAvailData(
        hours: json["hours"] ?? "",
        id: json["id"] ?? "",
        session: json["session"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "hours": hours,
        "session": session,
      };
}
