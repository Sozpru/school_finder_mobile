import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../Helper/helper.dart';

class HandleErrorsPage extends StatelessWidget {
  const HandleErrorsPage({Key? key, this.tryAgain, required this.errorType})
      : super(key: key);
  final VoidCallback? tryAgain;
  final String errorType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (errorType == "No Internet Connection")
            Lottie.asset(
              "assets/Anim/nointernetblack.json",
              width: 250.h,
              height: 250.h,
              frameRate: FrameRate(60),
            ),
          if (errorType == "Something went wrong")
            Lottie.asset(
              "assets/Anim/sww.json",
              width: 250.h,
              height: 250.h,
              frameRate: FrameRate(60),
            ),
          if (errorType == "Took longer to load !")
            Lottie.asset(
              "assets/Anim/tltl.json",
              width: 250.h,
              height: 250.h,
              frameRate: FrameRate(60),
            ),
          Text(
            errorType,
            maxLines: 3,
            style: Get.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SBH10(),
          if (tryAgain != null)
            ElevatedButton(
              onPressed: tryAgain,
              child: const Text("Try Again"),
            ),
        ],
      ),
    );
  }
}
