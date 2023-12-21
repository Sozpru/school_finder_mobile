class AskMeGetModel {
  bool? status;
  List<AskMeGetModelData>? data;
  String? msg;

  AskMeGetModel({this.status, this.data, this.msg});

  AskMeGetModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <AskMeGetModelData>[];
      json['data'].forEach((v) {
        data!.add(AskMeGetModelData.fromJson(v));
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

class AskMeGetModelData {
  String? id;
  String? username;
  String? question;
  String? answer;
  String? datetime;

  AskMeGetModelData({this.id, this.username, this.question, this.answer, this.datetime});

  AskMeGetModelData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    question = json['question'];
    answer = json['answer'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['question'] = question;
    data['answer'] = answer;
    data['datetime'] = datetime;
    return data;
  }
}