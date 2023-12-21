class StudentModel {
  bool? status;
  List<Data>? data;
  String? msg;

  StudentModel({this.status, this.data, this.msg});

  StudentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = msg;
    return data;
  }
}

class Data {
  String? mobileNo;
  String? username;
  String? standard;
  String? location;
  String? id;
  String? email;
  String? image;
  String? firebaseId;
  String? fcmToken;
  String? regDate;
  String? userType;
  String? type;
  String? password;
  String? facebookUserId;
  String? forgotPassToken;

  Data(
      {this.mobileNo,
      this.username,
      this.standard,
      this.location,
      this.id,
      this.email,
      this.image,
      this.firebaseId,
      this.fcmToken,
      this.regDate,
      this.userType,
      this.type,
      this.password,
      this.facebookUserId,
      this.forgotPassToken});

  Data.fromJson(Map<String, dynamic> json) {
    mobileNo = json['mobile_no'];
    username = json['username'];
    standard = json['standard'];
    location = json['location'];
    id = json['id'];
    email = json['email'];
    image = json['image'];
    firebaseId = json['firebase_id'];
    fcmToken = json['fcm_token'];
    regDate = json['reg_date'];
    userType = json['user_type'];
    type = json['type'];
    password = json['password'];
    facebookUserId = json['facebook_user_id'];
    forgotPassToken = json['forgot_pass_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobile_no'] = mobileNo;
    data['username'] = username;
    data['standard'] = standard;
    data['location'] = location;
    data['id'] = id;
    data['email'] = email;
    data['image'] = image;
    data['firebase_id'] = firebaseId;
    data['fcm_token'] = fcmToken;
    data['reg_date'] = regDate;
    data['user_type'] = userType;
    data['type'] = type;
    data['password'] = password;
    data['facebook_user_id'] = facebookUserId;
    data['forgot_pass_token'] = forgotPassToken;
    return data;
  }
}
