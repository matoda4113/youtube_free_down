import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'controller/data_controller.dart';
import 'main_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(DataController());

  Get.put(DataController());
  final DataController dataController = Get.find<DataController>();
  await dataController.getPath();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: MainPage(),
    );
  }
}

