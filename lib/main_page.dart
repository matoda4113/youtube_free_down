import 'package:flutter/material.dart';
import 'package:you_free_down/pages/download_screen.dart';
import 'package:you_free_down/pages/history_screen.dart';
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
    setState(() {
      _currentIndex = 0;
      _pageController = PageController(initialPage: 0);
    });
  }


  //일단 디폴트로 인덱스는 0임. 메인페이지의 홈 스크린을 가르킴
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appName),),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // YoutubeDownScreen(),
          DownloadScreen(),
          HistoryScreen(),
          Text(":")
        ],

      ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: appColorGray8, // 테두리 색상
                width: 1.0, // 테두리 두께
              ),
            ),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,

            onTap: (index) {
              // 탭이 선택되면 해당 페이지로 이동
              _pageController.jumpToPage(index);
            },

            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [

              BottomNavigationBarItem(
                  icon: Icon(Icons.video_collection_sharp , color: _currentIndex==0?appColorPrimary:appColorBlack),
                  label: ''
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle , color: _currentIndex==1?appColorPrimary:appColorBlack),
                  label: ''
              ),


            ],
          ),
        )
    );
  }
}
