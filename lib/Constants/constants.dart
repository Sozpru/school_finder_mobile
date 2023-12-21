import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:e_tutor/Models/standard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../Controller/my_controller.dart';
import '../Models/hours_avail_model.dart';
import '../Models/subject_model.dart';

const String appVersion = "1.0.1";
const Color appColor = Color(0xff345ea8);
const Color appColorS100 = Color(0xff345ea8);
const Color appDrawerColor = Color(0xffFFF8FD);
const Color appYellowButton = Color(0xfff6bd60);
const Color applightred = Color(0xffefa289);
const Color applightsky = Color(0xff88d1f0);
const Color applightpurple = Color(0xffb39ae5);
const Color appWhite = Color(0xffffffff);
const Color appgreyText = Color(0xffcccccc);
const Color appgreyHomeText = Color(0xff989898);
const Color appIconColor = Color(0xffcccccc);

const accessKey = 260898;

const google = 2;
const normal = 1;
const fb = 3;
const apple = 4;

bool isTestMode = true;

const intAdvId = "ca-app-pub-3940256099942544/1033173712";
const bannerAdvIdLive = "ca-app-pub-3940256099942544/1033173712";

const testDevice = "FCCEC7380A101293A08CB7DD285770D1";

const bannerAdvId = "ca-app-pub-3940256099942544/6300978111";
const bannerAdvIdIos = "ca-app-pub-3940256099942544/2934735716";


final GetStorage box = GetStorage();
final MyController myController = Get.find();

String getHashToken({required String name, required String email}) {
  String key = accessKey.toString() + name + email;
  var bytes = utf8.encode(key);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

List<SubjectDataModel> setArrayfromSeparated(
    String subjectId, List<SubjectDataModel>? subjectData) {
  final split = subjectId.split(',');
  final Map<int, String> values = {
    for (int i = 0; i < split.length; i++) i: split[i]
  };
  List<SubjectDataModel> subName = [];
  for (int j = 0; j < subjectData!.length; j++) {
    for (int k = 0; k < values.length; k++) {
      if (values[k] == subjectData[j].id) {
        var sub = subjectData[j];
        subName.add(sub);
      }
    }
  }
  return subName;
}

String getSringfromSubjectArray(
    String subjectId, List<SubjectDataModel?>? subjectData) {
  final split = subjectId.split(',');
  final Map<int, String> values = {
    for (int i = 0; i < split.length; i++) i: split[i]
  };
  List<String> subName = [];
  for (int j = 0; j < subjectData!.length; j++) {
    for (int k = 0; k < values.length; k++) {
      if (values[k] == subjectData[j]?.id) {
        var sub = subjectData[j]?.subjectName;
        subName.add(sub!);
      }
    }
  }
  return subName.join(" • ");
}

String getSringfromSTDArray(
    String subjectId, List<StandardDataModel?>? subjectData) {
  final split = subjectId.split(',');
  final Map<int, String> values = {
    for (int i = 0; i < split.length; i++) i: split[i]
  };
  List<String> subName = [];
  for (int j = 0; j < subjectData!.length; j++) {
    for (int k = 0; k < values.length; k++) {
      if (values[k] == subjectData[j]?.id) {
        var sub = subjectData[j]?.std;
        subName.add(sub!);
      }
    }
  }
  return subName.join(",");
}

String getSubjectStringSepComma(String subjectId) {
  List<String> subName = [];
  subName.add(subjectId);
  var ss = subName.join(",");
  return ss;
}

List<String> getMonthlyFees(String monthFees) {
  List<String> lsit = [];
  final split = monthFees.split(',');
  final Map<int, String> values = {
    for (int i = 0; i < split.length; i++) i: split[i]
  };
  for (int i = 0; i < values.length; i++) {
    lsit.add(values[i]!);
  }
  return lsit;
}

List<HoursAvailData> getHoursAvailArray(
    List<HoursAvailData?>? array, String sesion, String hurType) {
  List<HoursAvailData> lsit = [];
  List<HoursAvailData> lsitnew = [];
  final split = hurType.split(',');
  final Map<int, String> values = {
    for (int i = 0; i < split.length; i++) i: split[i]
  };

  for (int i = 0; i < array!.length; i++) {
    if (array[i]?.session == sesion) {
      lsit.add(array[i]!);
    }
  }

  for (int j = 0; j < lsit.length; j++) {
    for (int k = 0; k < values.length; k++) {
      if (values[k] == lsit[j].id) {
        // lsit[j].isSelected = true;
        lsitnew.add(lsit[j]);
      }
    }
  }
  return lsitnew;
}

String getHourssepComma(
    List<HoursAvailData?>? array, String aType, String mType) {
  List<String> lsit = [];
  String join = "";
  if (aType == "") {
    join = mType;
  } else if (mType == "") {
    join = aType;
  } else {
    join = "$aType,$mType";
  }

  final split = join.split(',');
  final Map<int, String> values = {
    for (int i = 0; i < split.length; i++) i: split[i]
  };

  for (int j = 0; j < array!.length; j++) {
    for (int k = 0; k < values.length; k++) {
      if (values[k] == array[j]!.id) {
        lsit.add(array[j]!.hours.toString());
      }
    }
  }
  return lsit.join(" , ");
}

String getTimeWithAMPM({required DateTime time}) {
  if (time.hour > 12) {
    final newTimeHour = time.hour - 12;
    return "${addPrefixZero(time: newTimeHour)}:${addPrefixZero(time: time.minute)} PM";
  } else if (time.hour == 12) {
    return "${addPrefixZero(time: time.hour)}:${addPrefixZero(time: time.minute)} PM";
  } else {
    return "${addPrefixZero(time: time.hour)}:${addPrefixZero(time: time.minute)} AM";
  }
}

String addPrefixZero({required int time}) {
  if (time < 10) {
    return "0$time";
  } else {
    return "$time";
  }
}

String getMonth({required int month}) {
  if (month == 1) {
    return "Jan";
  } else if (month == 2) {
    return "Feb";
  } else if (month == 3) {
    return "Mar";
  } else if (month == 4) {
    return "Apr";
  } else if (month == 5) {
    return "May";
  } else if (month == 6) {
    return "Jun";
  } else if (month == 7) {
    return "Jul";
  } else if (month == 8) {
    return "Aug";
  } else if (month == 9) {
    return "Sep";
  } else if (month == 10) {
    return "Oct";
  } else if (month == 11) {
    return "Nov";
  } else {
    return "Dec";
  }
}
