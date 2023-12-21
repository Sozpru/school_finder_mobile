class Student {
  bool status;
  List<StudentData>? data;
  String msg;

  Student({required this.status, this.data, required this.msg});

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<StudentData>.from(
                json["data"].map((x) => StudentData.fromJson(x))),
        msg: json["msg"],
      );

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

class StudentData {
  String? id;
  String? tutorEmail;
  String? studentEmail;
  String? subject;
  String? fees;
  String? status;
  String? mHours;
  String? aHours;
  String? tuitionType;
  String? username;
  String? image;
  String? sname;
  String? location;
  String? standard;
  String? mobileNo;
  String? pStatus;

  StudentData(
      {this.id,
      this.tutorEmail,
      this.pStatus,
      this.studentEmail,
      this.subject,
      this.fees,
      this.status,
      this.mHours,
      this.aHours,
      this.tuitionType,
      this.username,
      this.image,
      this.sname,
      this.location,
      this.standard,
      this.mobileNo});

  StudentData.fromJson(Map<String, dynamic> json) {
    pStatus = json['p_status'] ?? "";
    id = json['id'] ?? "";
    tutorEmail = json['tutor_email'] ?? "";
    studentEmail = json['student_email'] ?? "";
    subject = json['subject'] ?? "";
    fees = json['fees'] ?? "";
    status = json['status'] ?? "";
    mHours = json['m_hours'] ?? "";
    aHours = json['a_hours'] ?? "";
    tuitionType = json['tuition_type'] ?? "";
    username = json['username'] ?? "";
    image = json['image'] ?? "";
    sname = json['sname'] ?? "";
    location = json['location'] ?? "";
    standard = json['standard'] ?? "";
    mobileNo = json['mobile_no'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['p_status'] = pStatus;
    data['id'] = id;
    data['tutor_email'] = tutorEmail;
    data['student_email'] = studentEmail;
    data['subject'] = subject;
    data['fees'] = fees;
    data['status'] = status;
    data['m_hours'] = mHours;
    data['a_hours'] = aHours;
    data['tuition_type'] = tuitionType;
    data['username'] = username;
    data['image'] = image;
    data['sname'] = sname;
    data['location'] = location;
    data['standard'] = standard;
    data['mobile_no'] = mobileNo;
    return data;
  }
}
