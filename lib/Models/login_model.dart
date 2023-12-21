class LoginModel {
  bool status;
  String msg;
  String username;
  String type;

  LoginModel(
      {required this.status,
      required this.msg,
      required this.username,
      required this.type});

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        type: json["type"],
        msg: json["msg"],
        username: json["username"] ?? "",
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data["status"] = status;
    data["msg"] = msg;
    data["username"] = username;
    data["type"] = type;
    return data;
  }
}
