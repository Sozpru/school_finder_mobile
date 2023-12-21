import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginRoundedButton extends StatelessWidget {
  const LoginRoundedButton({Key? key, required this.path, required this.color})
      : super(key: key);
  final String? path;
  final int? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Column(children: [
      Container(
        decoration: BoxDecoration(
          color: Color(color!),
          shape: BoxShape.circle
        ),
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          path!,
          height: 30.h,
          width: 30.w,
        ),
      ),
    ]));
  }
}
