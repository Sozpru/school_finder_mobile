import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Constants/constants.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: appColor,
    colorScheme: const ColorScheme.light(primary: appColor),
    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appColor,
        padding: const EdgeInsets.all(12),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xffffffff),
    cardTheme: CardTheme(
      elevation: 2,
      margin: EdgeInsets.only(
        bottom: 8.h,
      ),
    ),
    iconTheme: IconThemeData(
      size: 16.h,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: const Color(0xffFFF8FD),
      iconTheme: IconThemeData(size: 25.h, color: appColor),
      titleTextStyle: GoogleFonts.roboto(
        fontWeight: FontWeight.w400,
        fontSize: 18.sp,
        color: Colors.black,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
        color: appColor,
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: GoogleFonts.roboto(
        color: appColor,
        fontSize: 22.sp,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.roboto(
        color: appColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: GoogleFonts.roboto(
        color: appColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: GoogleFonts.roboto(
        color: appgreyHomeText,
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.roboto(
        color: appColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(
        color: appYellowButton,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontSize: 40.sp,
      ),
    ).apply(fontSizeFactor: 1.0),
  );
}
