import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Constants/constants.dart';

class CPI extends StatelessWidget {
  const CPI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: appColor,
      ),
    );
  }
}

class SBH5 extends StatelessWidget {
  const SBH5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5.h,
    );
  }
}

class SBH1 extends StatelessWidget {
  const SBH1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1.h,
    );
  }
}

class SBH7 extends StatelessWidget {
  const SBH7({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7.h,
    );
  }
}

class SBH10 extends StatelessWidget {
  const SBH10({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: SizedBox(
          height: 10.h,
        ));
  }
}

class SBH20 extends StatelessWidget {
  const SBH20({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
    );
  }
}
// class TEXTLOGIN extends StatelessWidget {
//   const TEXTLOGIN({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//
//     );
//   }
// }

class SBW5 extends StatelessWidget {
  const SBW5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 5.w,
    );
  }
}

class SBW10 extends StatelessWidget {
  const SBW10({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10.w,
    );
  }
}

class SBW20 extends StatelessWidget {
  const SBW20({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.w,
    );
  }
}
