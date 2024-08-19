
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


///앱 칼라

const appColorPrimary = Color(0xFF5C4DD1);
const appColorPrimary2 = Color(0xFF100556);
const appColorBlack = Color(0xFF1B1D1F);
const appColorWhite = Color(0xFFFFFFFF);
const appColorDeepGray1 = Color(0xFF555555);

const appColorGray1 = Color(0xFF73787E);
const appColorGray2 = Color(0xFF7C7C7C);
const appColorGray3 = Color(0xFF929292);
const appColorGray4 = Color(0xFF9FA4A8);
const appColorGray5 = Color(0xFFBBBBBB);
const appColorGray6 = Color(0xFFCCCCCC);
const appColorGray7 = Color(0xFFD9D9D9);
const appColorGray8 = Color(0xFFE1E1E1);
const appColorRed1 = Color(0xFFFF0000);
const appColorRed2 = Color(0xFFDC6568);

String appName = "SaranVideo";

///SharedPreferences
late SharedPreferences prefs;

///로거
Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 1,
    lineLength: 130,
    colors: true,
    printEmojis: false,
    printTime: false,
  ),
);

String extractVideoId(String input) {
  RegExp regExp = RegExp(
    r'(?:(?:youtu\.be/|youtube\.com/watch\?v=)([^?&]+)|([a-zA-Z0-9_-]{11}))',
  );

  RegExpMatch? match = regExp.firstMatch(input);

  if (match != null) {
    // group(1)이 null이 아니면 그 값을, 그렇지 않으면 group(2)의 값을 반환합니다.
    String videoId = match?.group(1) ?? match.group(2)! ;

    return videoId;
  } else {
    // 일치하는 패턴이 없을 경우 기본값 또는 에러 처리
    return input; // 또는 throw Exception('Invalid input');
  }
}

String getNow(){
  // 현재 시간 가져오기
  DateTime now = DateTime.now();

  // 원하는 형식으로 변환하기 (yyyyMMddHHmmss)
  String formattedTime = DateFormat('yyyyMMddHHmmssSSS').format(now);

  return formattedTime;

}


