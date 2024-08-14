import 'package:flutter/material.dart';
import 'package:you_free_down/down_test_screen.dart';

import 'main.dart';

///MainPage
///담당자 : ---

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    logger.i("MainPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MainPage"),),
      body: DownTestScreen(),
    );
  }
}
