import 'dart:convert';
import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Models/stripe_payment_detail.dart';
import 'package:e_tutor/Views/CustomWidgets/show_snackbar.dart';
import 'package:e_tutor/Views/payment_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Helper/helper.dart';
import 'package:get/get.dart';
import '../Services/my_services.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'CustomWidgets/custom_dialogs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class PaymentPage extends StatefulWidget {
  PaymentPage(
      {Key? key, required this.pay, required this.email, required this.name})
      : super(key: key);
  String? email, pay,name;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntentData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight((size.height / 10)),
            child: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                systemNavigationBarColor: appColor, // Navigation bar
                statusBarColor: appColor, // Status bar
              ),
              titleSpacing: 30.h,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 25.h,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                "Payment Method",
                style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 19.sp),
              ),
              backgroundColor: appColor,
              shape: CustomAppBarShape(multi: 0.08.h),
            )),
        body: Column(
          children: [
            const SBH20(),
            const SBH20(),
            Text(
              "Select your payment method",
              style: GoogleFonts.roboto(
                  color: const Color(0xff626262),
                  fontWeight: FontWeight.w500,
                  fontSize: 17.sp),
            ),
            const SBH20(),
            const SBH20(),
            Expanded(
                flex: 6,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 18.w),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.06),
                          offset: Offset(
                            0.0,
                            0.0,
                          ),
                          blurRadius: 3.0,
                          spreadRadius: 3.0,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                    padding: EdgeInsets.all(10.h),
                                    child: Row(children: [
                                      const SBW5(),
                                      Image.asset(
                                        'assets/Images/ic_stripe.png',
                                        width: 47.w,
                                        height: 27.h,
                                      ),
                                      const SBW5(),
                                      Text(
                                        "Stripe",
                                        style: GoogleFonts.roboto(
                                            color: appColor,fontSize: 18.sp),
                                      ),
                                      Column(children: [
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Radio(
                                              activeColor: appColor,
                                              value: 1,
                                              groupValue: 1,
                                              onChanged: (val) {},
                                            ))
                                      ]),
                                    ])))
                          ],
                        )
                      ],
                    ))),
            Expanded(
                flex: 1,
                child: Container(
                    margin: EdgeInsets.symmetric(vertical : 8.h, horizontal: 18.w),
                    child:
                        Column(
                          children: [
                      SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: appYellowButton,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.r)),
                                        textStyle: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.normal)),
                                    onPressed: () async {
                                      CustomDialog.processDialog(
                                        loadingMessage: "Processing",
                                        successMessage: "Get data Successfully",
                                      );
                                      final resultdetail =
                                      await MyServices.getPayementDetail(
                                          widget.email!)
                                          .catchError(
                                            // ignore: body_might_complete_normally_catch_error
                                            (error, stackTrace) {
                                          myController.isProcessDone.value = 0;
                                          myController.processErrorMessage.value =
                                              error.toString();
                                        },
                                      );
                                      if (resultdetail != null) {
                                        if (resultdetail.status!) {
                                          myController.isProcessDone.value = 2;
                                          if (!mounted) return;
                                          Navigator.pop(context);
                                          String? key =
                                              resultdetail.data?.publishableKey;
                                          Stripe.publishableKey = key!;
                                          await makePayment(resultdetail.data);
                                        } else {
                                          myController.isProcessDone.value = 0;
                                          myController.processErrorMessage.value =
                                          resultdetail.msg!;
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Add",style: GoogleFonts.roboto(color: Colors.white,fontSize: 18.sp),
                                    ),
                                  )),
                          ],
                    ))),
          ],
        ));
  }

  Future<void> makePayment(PaymetDetailData? data) async {
    try {
      // final paymentMethod =
      // await Stripe.instance.createPaymentMethod(params: PaymentMethodParams.card(paymentMethodData: paymentMethodData));
      final billingDetails = BillingDetails(
        name: widget.name,
        email: widget.email,
        phone: '',
      );

      paymentIntentData = await createPaymentIntent(widget.pay!, 'USD', data);


      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  // setupIntentClientSecret: data!.secretKey,
                  customerEphemeralKeySecret: data!.secretKey,
                  paymentIntentClientSecret:
                      data.paymentIntent,
                  customerId: data.customer,
                  customFlow: true,
                  style: ThemeMode.dark,
                  billingDetails: billingDetails,
                  merchantDisplayName: 'E-School'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet(data);
    } catch (e) {
      ///now finally display payment sheeet
    }
  }

  displayPaymentSheet(PaymetDetailData data) async {
    try {
      await Stripe.instance
          .presentPaymentSheet()
          .then((newValue) async {

        Stripe.instance.confirmPaymentSheetPayment(
        ).then((paymentIntent) {
        });
        
        CustomDialog.processDialog(
          loadingMessage: "Processing",
          successMessage: "Payment done Successfully",
        );
        final resultdetail = await MyServices.setPayementDetail(
                widget.email!, paymentIntentData!['id'].toString())
            .catchError(
          // ignore: body_might_complete_normally_catch_error
          (error, stackTrace) {
            myController.isProcessDone.value = 0;
            myController.processErrorMessage.value = error.toString();
          },
        );
        if (resultdetail != null) {
          if (resultdetail.status!) {
            myController.isProcessDone.value = 2;

            if (!mounted) return;
            final navigator = Navigator.of(context); // store the Navigator
            navigator.pop();
            navigator.pop();
            Get.to(() => const PaymentDonePage());
          } else {
            myController.isProcessDone.value = 0;
            myController.processErrorMessage.value = resultdetail.msg!;
          }
        }
        if (!mounted) return;
        showSnackBar(context, "Paid successfully");

        paymentIntentData = null;
      }).onError((error, stackTrace) {
      });
    } on StripeException {
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      //
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(
      String amount, String currency, PaymetDetailData? data) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(widget.pay!),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ${data!.secretKey!}',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (err) {
      //
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 10;
    return a.toString();
  }
}
