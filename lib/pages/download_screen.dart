import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:you_free_down/pages/youtube_screen.dart';

import '../component/custom_input_filed.dart';
import '../controller/data_controller.dart';
import '../global/global.dart';
import '../vo/youtube_video_info_vo.dart';

///DownloadScreen
///담당자 : ---

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {

  @override
  void initState() {
    super.initState();
    logger.i("DownloadScreen");
  }

  bool isSearching = false;
  String? videoUrl;

  YoutubeVideoInfoVo? video;

  final TextEditingController _searchController = TextEditingController();
  DataController _dataController = Get.find<DataController>();
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataController>(

        builder: (dataController) {
          double screenWidth = MediaQuery.of(context).size.width;
          return Column(
            children: [
              Row(
                children: [

                  ElevatedButton(
                      onPressed: (){
                        setState(() {
                          _currentIndex =0;
                          _pageController.jumpToPage(0);
                        });
                      },
                      child: Row(
                        children: [
                          Brand(Brands.youtube),
                          Text("YouTube"),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                      foregroundColor: appColorBlack,
                      backgroundColor: _currentIndex==0?Colors.red.withOpacity(0.2):Colors.white,
                      overlayColor: Colors.red,
                        elevation: _currentIndex==0?10:1,
                    ),

                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _currentIndex =1;
                        _pageController.jumpToPage(1);
                      });
                    },
                    child: Row(
                      children: [
                        Brand(Brands.instagram),
                        Text("Instargram"),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: appColorBlack,
                      backgroundColor: _currentIndex==1?Colors.purple.withOpacity(0.2):Colors.white,
                      overlayColor: Colors.purple,
                      elevation: _currentIndex==1?10:1,
                    ),

                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: (){
                      setState(() {
                        _currentIndex =2;
                        _pageController.jumpToPage(2);
                      });
                    },
                    child: Row(
                      children: [
                        Brand(Brands.tiktok),
                        Text("TicTok"),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: appColorBlack,
                      backgroundColor: _currentIndex==2?Colors.black.withOpacity(0.2):Colors.white,
                      overlayColor: Colors.black,
                      elevation: _currentIndex==2?10:1,
                    ),

                  ),


                ],
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    YoutubeScreen(),

                    Text("2"),
                    Text("3"),
                  ],

                ),
              ),
            ],
          );
        }
    );
  }
}
