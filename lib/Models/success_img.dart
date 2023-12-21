class SuccessImg {
  bool? status;
  String? msg;
  String? imageurl;

  SuccessImg({this.status, this.msg});

  SuccessImg.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    imageurl = json['imageurl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    data['imageurl'] = imageurl;
    return data;
  }
}
