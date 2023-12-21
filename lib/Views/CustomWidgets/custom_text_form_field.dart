import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Constants/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TFF extends StatelessWidget {
  const TFF(
      {Key? key,
      this.validator,
      this.controler,
      required this.color,
      required this.onSaved,
      required this.hintText,
      this.initialValue,
      this.obscureText,
      this.keyboardType,
      this.prefixIcon,
      required this.align})
      : super(key: key);
  final FormFieldValidator<String>? validator;
  final TextEditingController? controler;
  final FormFieldSetter<String>? onSaved;
  final String hintText;
  final TextAlign align;
  final Color color;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controler,
      textAlign: align,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
      cursorColor: const Color.fromRGBO(98, 98, 98, 1),
      textAlignVertical: TextAlignVertical.center,
      style: GoogleFonts.roboto(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: const Color.fromRGBO(98, 98, 98, 1),
      ),
      obscureText: obscureText ?? false,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        prefixIcon: prefixIcon,
        // fillColor: const Color.fromRGBO(61, 78, 176, 0.09),
        fillColor: color,
        hintStyle: GoogleFonts.roboto(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: appgreyHomeText,
        ),
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none),

        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none),
      ),
      onSaved: onSaved,
    );
  }
}
