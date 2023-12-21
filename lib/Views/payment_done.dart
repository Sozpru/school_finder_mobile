import 'package:e_tutor/Constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Helper/helper.dart';
import 'CustomWidgets/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottom_navigation.dart';

class PaymentDonePage extends StatefulWidget {
  const PaymentDonePage({Key? key}) : super(key: key);

  @override
  State<PaymentDonePage> createState() => _PaymentDonePageState();
}

class _PaymentDonePageState extends State<PaymentDonePage> {
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
                "Payment",
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
            const SBH20(),
            Image.asset(
              "assets/Anim/check.gif",
              height: 111.h,
              width: 111.w,
            ),
            Text(
              "Successfully!",
              style: GoogleFonts.roboto(
                  color: const Color.fromRGBO(98, 98, 98, 1),
                  fontWeight: FontWeight.w500,
                  fontSize: 32.sp),
            ),
            const SBH20(),
            Text(
              "Your Payment is successfully done",
              style: GoogleFonts.roboto(
                  color: const Color.fromRGBO(152, 152, 152, 1),
                  fontWeight: FontWeight.w400,
                  fontSize: 18.sp),
            ),
            const SBH20(),
            const SBH20(),
            const SBH20(),
            const SBH20(),
            Padding(
                padding: EdgeInsets.all(10.h),
                child: SizedBox(
                    width: double.infinity,
                    height: 47.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: appYellowButton,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.normal)),
                      onPressed: () async {
                        Get.offAll(() => const BottomNavigation());
                      },
                      child: Text(
                        "Done",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp),
                      ),
                    )))
          ],
        ));
  }
}
