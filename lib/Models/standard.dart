import 'dart:convert';

StandardModel itemStockModelFromJson(String str) =>
    StandardModel.fromJson(json.decode(str));

class StandardModel {
  StandardModel({
    required this.status,
    this.data,
    required this.msg,
  });

  bool status;
  List<StandardDataModel>? data;
  String msg;

  factory StandardModel.fromJson(Map<String, dynamic> json) => StandardModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<StandardDataModel>.from(
                json["data"].map((x) => StandardDataModel.fromJson(x))),
        msg: json["msg"],
      );

// Map<String, dynamic> toJson() => {
//   "status": status,
//   "data": List<dynamic>.from(data.map((x) => x.toJson())),
//   "msg": msg,
// };
}

class StandardDataModel {
  StandardDataModel({
    required this.id,
    required this.std,
  });

  String? id;
  String? std;
  bool isSelected = false;

  factory StandardDataModel.fromJson(Map<String, dynamic> json) =>
      StandardDataModel(
        std: json["std"] ?? "",
        id: json["id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "std": std,
      };
}
