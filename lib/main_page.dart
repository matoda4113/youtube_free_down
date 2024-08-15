import 'package:flutter/material.dart';
import 'package:you_free_down/youtube_down_screen.dart';

import 'global/global.dart';
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
      appBar: AppBar(title: Text("유튜브 다운"),),
      body: YoutubeDownScreen(),
    );
  }
}
