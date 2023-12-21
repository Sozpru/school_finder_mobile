class PaymentDetail {
  bool? status;
  PaymetDetailData? data;
  String? msg;

  PaymentDetail({this.status, this.data, this.msg});

  PaymentDetail.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data =
        json['data'] != null ? PaymetDetailData.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = msg;
    return data;
  }
}

class PaymetDetailData {
  String? paymentIntent;
  String? secretKey;
  String? customer;
  String? publishableKey;

  PaymetDetailData(
      {this.paymentIntent, this.secretKey, this.customer, this.publishableKey});

  PaymetDetailData.fromJson(Map<String, dynamic> json) {
    paymentIntent = json['paymentIntent'];
    secretKey = json['secretKey'];
    customer = json['customer'];
    publishableKey = json['publishableKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentIntent'] = paymentIntent;
    data['secretKey'] = secretKey;
    data['customer'] = customer;
    data['publishableKey'] = publishableKey;
    return data;
  }
}
