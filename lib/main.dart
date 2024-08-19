import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:desktop_window/desktop_window.dart';
import 'controller/data_controller.dart';
import 'global/global.dart';
import 'main_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(DataController());


  final DataController dataController = Get.find<DataController>();
  await dataController.getPath();
  // Size size = await DesktopWindow.getWindowSize();
  // logger.i(size);
  //
  await DesktopWindow.setMinWindowSize(Size(700,600));
  // await DesktopWindow.setWindowSize(Size(size.width,size.height));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      home: MainPage(),
    );
  }
}

