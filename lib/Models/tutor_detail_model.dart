
class TutorDetailModel {
  bool status;
  List<Data> data;
  String msg;

  TutorDetailModel({required this.status, required this.data, required this.msg});

  factory TutorDetailModel.fromJson(Map<String, dynamic> json) =>
      TutorDetailModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['data'] = this.data.map((v) => v.toJson()).toList();
    data['msg'] = msg;
    return data;
  }
}

class Data {
  String? id;
  String? username;
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
  String? standard;
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
  String? subjectName;
  String? rate;
  String? distance;

  Data(
      {this.id,
      this.username,
      this.email,
      this.image,
      this.firebaseId,
      this.fcmToken,
      this.regDate,
      this.userType,
      this.type,
      this.password,
      this.facebookUserId,
      this.forgotPassToken,
      this.standard,
      this.subject,
      this.monthlyFees,
      this.university,
      this.location,
      this.yearOfExperience,
      this.mobileNo,
      this.datetime,
      this.latitude,
      this.longitude,
      this.tuitionType,
      this.mHours,
      this.aHours,
      this.subjectName,
      this.rate,
      this.distance});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    username = json['username'] ?? "";
    email = json['email'] ?? "";
    image = json['image'] ?? "";
    firebaseId = json['firebase_id'] ?? "";
    fcmToken = json['fcm_token'] ?? "";
    regDate = json['reg_date'] ?? "";
    userType = json['user_type'] ?? "";
    type = json['type'] ?? "";
    password = json['password'] ?? "";
    facebookUserId = json['facebook_user_id'] ?? "";
    forgotPassToken = json['forgot_pass_token'] ?? "";
    standard = json['standard'] ?? "";
    subject = json['subject'] ?? "";
    monthlyFees = json['monthly_fees'] ?? "";
    university = json['university'] ?? "";
    location = json['location'] ?? "";
    yearOfExperience = json['year_of_experience'] ?? "";
    mobileNo = json['mobile_no'] ?? "";
    datetime = json['datetime'] ?? "";
    latitude = json['latitude'] ?? "";
    longitude = json['longitude'] ?? "";
    tuitionType = json['tuition_type'] ?? "";
    mHours = json['m_hours'] ?? "";
    aHours = json['a_hours'] ?? "";
    subjectName = json['subject_name'] ?? "";
    rate = json['rate'] ?? "";
    distance = json['distance'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
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
    data['standard'] = standard;
    data['subject'] = subject;
    data['monthly_fees'] = monthlyFees;
    data['university'] = university;
    data['location'] = location;
    data['year_of_experience'] = yearOfExperience;
    data['mobile_no'] = mobileNo;
    data['datetime'] = datetime;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['tuition_type'] = tuitionType;
    data['m_hours'] = mHours;
    data['a_hours'] = aHours;
    data['subject_name'] = subjectName;
    data['rate'] = rate;
    data['distance'] = distance;
    return data;
  }
}
