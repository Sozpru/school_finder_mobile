import 'dart:convert';

SubjectModel itemStockModelFromJson(String str) =>
    SubjectModel.fromJson(json.decode(str));

SubjectModel kitModelFromMap(String str) =>
    SubjectModel.fromMap(json.decode(str));

String kitModelToMap(SubjectModel data) => json.encode(data.toMap());

class SubjectModel {
  SubjectModel({
    required this.status,
    this.data,
    required this.msg,
  });

  bool status;
  List<SubjectDataModel>? data;
  String msg;

  factory SubjectModel.fromMap(Map<String, dynamic> json) => SubjectModel(
        status: json["status"],
        data: json["data"],
        msg: json["msg"],
      );

  Map<String, dynamic> toMap() => {
        "status": status,
        "data": data,
        "msg": msg,
      };


  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<SubjectDataModel>.from(
                json["data"].map((x) => SubjectDataModel.fromJson(x))),
        msg: json["msg"],
      );
}

class SubjectDataModel {
  SubjectDataModel({this.id, this.subjectName, this.image});

  String? id;
  bool isSelected = false;
  String price = "";
  String? subjectName;
  String? image;

  factory SubjectDataModel.fromJson(Map<String, dynamic> json) =>
      SubjectDataModel(
        subjectName: json["subject_name"] ?? "",
        id: json["id"] ?? "",
        image: json["image"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "subject_name": subjectName,
      };
}
