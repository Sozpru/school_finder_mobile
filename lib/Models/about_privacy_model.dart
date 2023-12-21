import 'dart:convert';

AboutPrivacyModel itemStockModelFromJson(String str) =>
    AboutPrivacyModel.fromJson(json.decode(str));

class AboutPrivacyModel {
  AboutPrivacyModel({
    required this.status,
    this.data,
    required this.msg,
  });

  bool status;
  List<AboutDataModel>? data;
  String msg;

  factory AboutPrivacyModel.fromJson(Map<String, dynamic> json) =>
      AboutPrivacyModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<AboutDataModel>.from(
                json["data"].map((x) => AboutDataModel.fromJson(x))),
        msg: json["msg"],
      );

// Map<String, dynamic> toJson() => {
//   "status": status,
//   "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   "msg": msg,
// };
}

class AboutDataModel {
  AboutDataModel({
    required this.id,
    required this.notificationStatus,
    required this.privacyPolicy,
    required this.about,
  });

  String? id;
  String? notificationStatus;
  String? about, privacyPolicy;

  factory AboutDataModel.fromJson(Map<String, dynamic> json) => AboutDataModel(
        notificationStatus: json["notification_status"] ?? "",
        about: json["about"] ?? "",
        privacyPolicy: json["privacy_policy"] ?? "",
        id: json["id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "about": about,
        "notification_status": notificationStatus,
        "privacy_policy": privacyPolicy,
        "id": id,
      };
}
