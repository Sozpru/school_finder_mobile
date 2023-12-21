
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../Constants/constants.dart';
import '../Views/CustomWidgets/custom_app_bar.dart';

class ShowPdfPage extends StatefulWidget {
  const ShowPdfPage({super.key, required this.arguments});

  final String arguments;

  @override
  ShowPdfPageState createState() => ShowPdfPageState();
}

class ShowPdfPageState extends State<ShowPdfPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((size.height / 10)),
          child: AppBar(
            centerTitle: true,
            systemOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: appColor, // Navigation bar
              statusBarColor: appColor, // Status bar
            ),
            titleSpacing: 30.w,
            leading: IconButton(
              icon:  Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 25.sp,
              ),
              onPressed: () =>
                  Navigator.pop(context),
            ),
            title: Text("PDF",
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 19),
            ),
            backgroundColor: appColor,
            shape: const CustomAppBarShape(multi: 0.08),
          )),
      body: SafeArea(
        child: Expanded(child:SfPdfViewer.network(
          widget.arguments,) ),
      ),
    );
  }
}