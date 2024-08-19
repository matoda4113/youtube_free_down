import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../component/custom_input_filed.dart';
import '../controller/data_controller.dart';
import '../global/global.dart';
import '../vo/youtube_video_info_vo.dart';

///YoutubeScreen
///담당자 : ---

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({Key? key}) : super(key: key);

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen>  with AutomaticKeepAliveClientMixin{


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    logger.i("YoutubeScreen");
  }

  bool searchNow = false;
  String? videoUrl;

  YoutubeVideoInfoVo? video;
  final TextEditingController _searchController = TextEditingController();
  DataController _dataController = Get.find<DataController>();
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Brand(Brands.youtube),
              Text("Youtube Video Download"),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomInputFiled(
                  isDense: true,
                  controller: _searchController,
                  fillColor: appColorGray8,
                  borderRadius: 5,
                  contentsPaddingVertical: 10,
                  onChanged: (val) {
                    setState(() {
                      setState(() {
                        videoUrl = val;
                      });
                    });
                  },
                  suffix: false,
                ),
              ),
              SizedBox(width: 10,),
              ElevatedButton(onPressed: () async{
                if(videoUrl != null){

                  setState(() {
                    searchNow = true;
                  });
                  try{
                    video =  await _dataController.getYoutubeInfo(videoUrl!);
                    setState(() {
                      searchNow = false;
                    });
                  }catch(e){
                    setState(() {
                      video = null;
                      searchNow = false;
                    });
                  }
                }

              }, child: Icon(Icons.search)),
            ],
          ),
          SizedBox(height: 10,),
          Expanded(
              child:searchNow
                  ?Center(child: CircularProgressIndicator())
                  :video==null?Center(child: Text("영상 없음")):Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Expanded(
                    child: Container(

                      child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start ,
                        children: [
                          ExtendedImage.network(
                            video?.video?.thumbnails.highResUrl??"",
                            fit: BoxFit.contain,
                            cache: true,
                            loadStateChanged: (ExtendedImageState state) {
                              if (state.extendedImageLoadState == LoadState.failed) {
                                return Text("NoImage");
                              }
                            },
                          ),
                          SizedBox(width: 20,),
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(video?.video?.duration?.toString()??""),
                                  Text(video?.video?.title??""),
                                  Text(video?.video?.author.toString()??""),
                                  SizedBox(height: 20,),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: video?.mixList?.length??0,
                                    separatorBuilder: (context,index){
                                      return SizedBox(height: 10,);
                                    },
                                    itemBuilder: (context, index) {
                              
                                      String title = "${video!.video!.title}_${video!.mixList![index].qualityLabel}";
                                      String mediaType = "commonMix";
                                      String mediaKey = title+"${video!.mixList![index].container.name}"+"${video!.mixList[index].size.totalMegaBytes}"+mediaType;
                                      String spec = "(${video!.mixList![index].qualityLabel},${video!.mixList![index].container.name},${video!.mixList![index].size.totalMegaBytes.toStringAsFixed(2)}MB)";

                              
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Obx(() {
                                                return SizedBox(
                                                  width: 80,
                                                  child: ElevatedButton(onPressed: () async{
                                                    if(_dataController.downloadingNow[mediaKey]==true){
                              
                                                    }else{
                                                      try{
                                                        await _dataController.downloadCommon(title: title!, streamInfo: video!.mixList![index], type: mediaType,mediaKey: mediaKey);
                                                        _dataController.openRootDir();
                                                      }catch(e){
                                                        logger.e(e);
                                                      }finally{
                              
                                                      }
                                                    }
                              
                                                  }, child:_dataController.downloadingNow[mediaKey]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download)),
                                                );
                                              }),
                                              SizedBox(width: 10,),
                                              Text(spec,style: TextStyle(fontSize: 10),),
                                            ],
                                          ),
                                          SizedBox(height: 5,),
                                          Obx(() {
                                            return _dataController.downloadProgressMap[mediaKey]==null
                                                ?SizedBox()
                                                :_dataController.downloadProgressMap[mediaKey]==1.0
                                                ?GestureDetector(onTap: (){
                                              _dataController.openRootDir();
                                            }, child: Text("다운로드 완료",style: TextStyle(color: Colors.greenAccent,fontSize: 10),))
                                                :Row(
                                                  children: [
                                                    SizedBox(
                                                                                                  width: 150,
                                                                                                  child: LinearProgressIndicator(
                                                    value: _dataController.downloadProgressMap[mediaKey],
                                                    minHeight: 10.0, // 높이 설정
                                                    backgroundColor: Colors.grey[300],
                                                    color: Colors.blue,
                                                                                                  ),
                                                                                                ),
                                                    Text((_dataController.downloadProgressMap[mediaKey]! * 100.0).toStringAsFixed(1)+"%",style: TextStyle(fontSize: 10),)
                                                  ],
                                                );
                              
                                          })
                                        ],
                                      );
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Text("캡션복사"),
                                      SizedBox(width: 10,),
                                      GestureDetector(
                                          onTap: (){
                                            if(video?.caption != null){
                                              Clipboard.setData(ClipboardData(text: video!.caption!));
                                              // 복사 완료 알림
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("클립보드에 복사완료")),
                                              );
                                            }
                              
                                          },
                                          child: Icon(Icons.copy,size: 15,)),
                                    ],
                                  ),
                                  CustomInputFiled(

                                    fillColor: appColorGray8,
                                    borderRadius: 5,
                                    initialValue:"${video?.caption??"캡션없음"}",
                                    contentsPaddingVertical: 10,
                                    readOnly: true,
                                    maxLine: 20,
                                    onChanged: (val) {

                                    },
                                    suffix: false,
                                  ),

                              
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [

                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _currentIndex = 0;
                                });
                                _pageController.jumpToPage(0);
                              },
                              child: Container(
                                  width: 70,
                                  height: 20,

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: _currentIndex==0?Colors.pinkAccent:appColorGray8,
                                  ),
                                  child: Center(child: Text("mix"))),
                            ),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _currentIndex = 1;
                                });
                                _pageController.jumpToPage(1);
                              },
                              child: Container(
                                  width: 70,
                                  height: 20,

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: _currentIndex==1?Colors.blue:appColorGray8,
                                  ),
                                  child: Center(child: Text("video"))),
                            ),
                            SizedBox(width: 5,),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _currentIndex = 2;
                                });
                                _pageController.jumpToPage(2);
                              },
                              child: Container(
                                  width: 70,
                                  height: 20,

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: _currentIndex==2?Colors.orange:appColorGray8,
                                  ),
                                  child: Center(child: Text("audio"))),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5,),
                                  Text("(*video+audio혼합)"),
                                  SizedBox(height: 5,),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: video!.videoOnlyList.length,
                                      separatorBuilder: (context,index){
                                        return video!.videoOnlyList[index].container.name=="mp4"?SizedBox(height: 10,):SizedBox();
                                      },
                                      itemBuilder: (context, index) {

                                        String title = "${video!.video!.title}_${video!.videoOnlyList![index].qualityLabel}";
                                        String mediaKeyVideo = title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}+videoOnly";
                                        String mediaKeyAudio = title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}+audioOnly";
                                        String spec = "(${video!.videoOnlyList[index].qualityLabel},${video!.videoOnlyList[index].container.name},${video!.videoOnlyList[index].size.totalMegaBytes.toStringAsFixed(2)}MB+a)";

                                        return video!.videoOnlyList[index].container.name=="mp4"?Row(
                                          children: [

                                            Obx(() {
                                              return SizedBox(
                                                width: 80,
                                                child: ElevatedButton(onPressed: () async{
                                                  if(_dataController.downloadingNow[mediaKeyVideo+"mix"]==true){
                                                  }else{
                                                    try{
                                                      await _dataController.downloadMerge(title: title!, streamInfoVideo: video!.videoOnlyList![index], streamInfoAudio: video!.audioOnlyList!.first ,mediaKeyVideo: mediaKeyVideo ,mediaKeyAudio:mediaKeyAudio, );
                                                      _dataController.openRootDir();
                                                    }catch(e){
                                                      logger.e(e);
                                                    }finally{
                                                    }
                                                  }

                                                }, child:_dataController.downloadingNow[mediaKeyVideo+"mix"]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download)),
                                              );
                                            }),



                                            SizedBox(width: 10,),
                                            Text(spec,style: TextStyle(fontSize: 10),),
                                            SizedBox(width: 10,),
                                            Stack(
                                              children: [
                                                Obx(() {
                                                  return _dataController.mergeProgressMap[mediaKeyVideo]==null
                                                      ?SizedBox()
                                                      :_dataController.mergeProgressMap[mediaKeyVideo]==1.0
                                                      ?SizedBox()
                                                      :Row(
                                                        children: [
                                                          SizedBox(
                                                                                                              width: 50,
                                                                                                              child: LinearProgressIndicator(
                                                          value: _dataController.mergeProgressMap[mediaKeyVideo],
                                                          minHeight: 10.0, // 높이 설정
                                                          backgroundColor: Colors.grey[300],
                                                          color: Colors.blue,
                                                                                                              ),
                                                                                                            ),
                                                          Text((_dataController.mergeProgressMap[mediaKeyVideo]! * 100.0).toStringAsFixed(1)+"%",style: TextStyle(fontSize: 10),)
                                                        ],
                                                      );

                                                }),
                                                Obx(() {
                                                  return _dataController.mergeProgressMap[mediaKeyAudio]==null
                                                      ?SizedBox()
                                                      :_dataController.mergeProgressMap[mediaKeyAudio]==1.0
                                                      ?SizedBox()
                                                      :Row(
                                                        children: [
                                                          SizedBox(
                                                                                                              width: 50,
                                                                                                              child: LinearProgressIndicator(
                                                          value: _dataController.mergeProgressMap[mediaKeyAudio],
                                                          minHeight: 10.0, // 높이 설정
                                                          backgroundColor: Colors.grey[300],
                                                          color: Colors.orange,
                                                                                                              ),
                                                                                                            ),
                                                          Text((_dataController.mergeProgressMap[mediaKeyAudio]! * 100.0).toStringAsFixed(1)+"%",style: TextStyle(fontSize: 10),)
                                                        ],
                                                      );

                                                }),
                                                Obx(() {
                                                  return _dataController.mergeProgressMap[mediaKeyVideo+"mix"]==null
                                                      ?SizedBox()
                                                      :_dataController.mergeProgressMap[mediaKeyVideo+"mix"]==1.0
                                                      ?GestureDetector(onTap: (){
                                                    _dataController.openRootDir();
                                                  }, child: Text("다운로드 완료",style: TextStyle(color: Colors.greenAccent,fontSize: 10),))
                                                      :Row(
                                                        children: [
                                                          SizedBox(
                                                                                                              width: 50,
                                                                                                              child: LinearProgressIndicator(
                                                          value: _dataController.mergeProgressMap[mediaKeyVideo+"mix"],
                                                          minHeight: 10.0, // 높이 설정
                                                          backgroundColor: Colors.grey[300],
                                                          color: Colors.pinkAccent,
                                                                                                              ),
                                                                                                            ),
                                                          Text((_dataController.mergeProgressMap[mediaKeyVideo+"mix"]! * 100.0).toStringAsFixed(1)+"%",style: TextStyle(fontSize: 10),)
                                                        ],
                                                      );

                                                })
                                              ],
                                            ),

                                          ],
                                        ):SizedBox();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5,),
                                  Text("(*video only 음성없는 영상파일)"),
                                  SizedBox(height: 5,),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: video!.videoOnlyList.length,
                                      separatorBuilder: (context,index){
                                        return SizedBox(height: 10,);
                                      },
                                      itemBuilder: (context, index) {
                                        String title = "${video!.video!.title}_${video!.videoOnlyList![index].qualityLabel}";
                                        String mediaType = "videoOnly";
                                        String mediaKey = title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+mediaType;
                                        String spec = "(${video!.videoOnlyList[index].qualityLabel},${video!.videoOnlyList[index].container.name},${video!.videoOnlyList[index].size.totalMegaBytes.toStringAsFixed(2)}MB)";
                                        return Row(
                                          children: [
                                            Obx(() {
                                              return SizedBox(
                                                width: 80,
                                                child: ElevatedButton(onPressed: () async{
                                                  if(_dataController.downloadingNow[mediaKey]==true){
                                                  }else{
                                                    try{
                                                      await _dataController.downloadCommon(title: title!, streamInfo: video!.videoOnlyList![index], type: mediaType , mediaKey: mediaKey);
                                                      _dataController.openRootDir();
                                                    }catch(e){
                                                      logger.e(e);
                                                    }finally{
                                                    }
                                                  }
                                                }, child:_dataController.downloadingNow[mediaKey]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download,)),
                                              );
                                            }),
                                            SizedBox(width: 10,),
                                            Text(spec,style: TextStyle(fontSize: 10),),
                                            SizedBox(width: 10,),
                                            Obx(() {
                                              return _dataController.downloadProgressMap[mediaKey]==null
                                                  ?SizedBox()
                                                  :_dataController.downloadProgressMap[mediaKey]==1.0
                                                  ?GestureDetector(onTap: (){
                                                _dataController.openRootDir();
                                              }, child: Text("다운로드 완료",style: TextStyle(color: Colors.greenAccent,fontSize: 10),))
                                                  :Row(
                                                    children: [
                                                      SizedBox(
                                                                                                      width: 50,
                                                                                                      child: LinearProgressIndicator(
                                                      value: _dataController.downloadProgressMap[mediaKey],
                                                      minHeight: 10.0, // 높이 설정
                                                      backgroundColor: Colors.grey[300],
                                                      color: Colors.blue,
                                                                                                      ),
                                                                                                    ),
                                                      Text((_dataController.downloadProgressMap[mediaKey]! * 100.0).toStringAsFixed(1)+"%",style: TextStyle(fontSize: 10),)
                                                    ],
                                                  );

                                            })

                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5,),
                                  Text("(*audio only 영상없는 음성파일)"),
                                  SizedBox(height: 5,),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: video!.audioOnlyList.length,
                                      separatorBuilder: (context,index){
                                        return SizedBox(height: 10,);
                                      },
                                      itemBuilder: (context, index) {
                                        String title = "${video!.video!.title}_${video!.audioOnlyList![index].qualityLabel}";
                                        String mediaType = "audioOnly";
                                        String mediaKey = title+"${video!.audioOnlyList![index].container.name}"+"${video!.audioOnlyList[index].size.totalMegaBytes}"+mediaType;
                                        String spec = "(${video!.audioOnlyList[index].qualityLabel},${video!.audioOnlyList[index].container.name},${video!.audioOnlyList[index].size.totalMegaBytes.toStringAsFixed(2)}MB)";
                                        return Row(
                                          children: [
                                            Obx(() {
                                              return SizedBox(
                                                width: 80,
                                                child: ElevatedButton(onPressed: () async{
                                                  if(_dataController.downloadingNow[mediaKey]==true){
                                                  }else{
                                                    try{
                                                      await _dataController.downloadCommon(title: title!, streamInfo: video!.videoOnlyList![index], type: mediaType , mediaKey: mediaKey);
                                                      _dataController.openRootDir();
                                                    }catch(e){
                                                      logger.e(e);
                                                    }finally{
                                                    }
                                                  }
                                                }, child:_dataController.downloadingNow[mediaKey]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download,)),
                                              );
                                            }),
                                            SizedBox(width: 10,),
                                            Text(spec,style: TextStyle(fontSize: 10),),
                                            SizedBox(width: 10,),
                                            Obx(() {
                                              return _dataController.downloadProgressMap[mediaKey]==null
                                                  ?SizedBox()
                                                  :_dataController.downloadProgressMap[mediaKey]==1.0
                                                  ?GestureDetector(onTap: (){
                                                _dataController.openRootDir();
                                              }, child: Text("다운로드 완료",style: TextStyle(color: Colors.greenAccent,fontSize: 10),))
                                                  :Row(
                                                    children: [
                                                      SizedBox(
                                                                                                      width: 50,
                                                                                                      child: LinearProgressIndicator(
                                                      value: _dataController.downloadProgressMap[mediaKey],
                                                      minHeight: 10.0, // 높이 설정
                                                      backgroundColor: Colors.grey[300],
                                                      color: Colors.orange,
                                                                                                      ),
                                                                                                    ),
                                                      Text((_dataController.downloadProgressMap[mediaKey]! * 100.0).toStringAsFixed(1)+"%",style: TextStyle(fontSize: 10),)
                                                    ],
                                                  );

                                            })

                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],

                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              )
          ),
          

        ],
      ),
    );
  }
}
