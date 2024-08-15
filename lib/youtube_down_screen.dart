import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:you_free_down/controller/data_controller.dart';
import 'package:you_free_down/global/global.dart';
import 'package:you_free_down/vo/youtube_video_info_vo.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'component/custom_input_filed.dart';
import 'main.dart';

///YoutubeDownScreen
///담당자 : ---

class YoutubeDownScreen extends StatefulWidget {
  const YoutubeDownScreen({Key? key}) : super(key: key);

  @override
  State<YoutubeDownScreen> createState() => _YoutubeDownScreenState();
}

class _YoutubeDownScreenState extends State<YoutubeDownScreen> {

  @override
  void initState() {
    super.initState();

  }



  bool isLoading = false;
  bool isSearcing = false;
  String? videoUrl;

  YoutubeVideoInfoVo? video;

  final TextEditingController _searchController = TextEditingController();
  DataController _dataController = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DataController>(
      builder: (dataController) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("링크 : ",style: TextStyle(fontSize: 20),),
                      Expanded(
                        child: CustomInputFiled(

                          controller: _searchController,
                          fillColor: appColorGray7,
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
                            isSearcing = true;
                          });
                          try{
                            video =  await dataController.getYoutubeInfo(videoUrl!);
                            setState(() {
                              isSearcing = false;
                            });
                          }catch(e){
                            setState(() {
                              video = null;
                              isSearcing = false;
                            });
                          }
                        }

                      }, child: Icon(Icons.search)),
                    ],
                  ),
                  SizedBox(height: 30,),

                  GestureDetector(
                      onTap: (){
                        dataController.openFinder(dataController.appDocumentsDir!.path!);

                      },
                      child: Text("파일경로 : ${dataController.appDocumentsDir!.path!}")),
                  SizedBox(height: 30,),
                    video==null ? Expanded(child: Center(child: Text("해당 영상 없음",style: TextStyle(fontSize: 50),))):isSearcing?Expanded(child: Center(child: CircularProgressIndicator())): Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Image.network(video?.video?.thumbnails.highResUrl??"",height: 200),
                              SizedBox(width: 20,),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 200,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(video?.video?.duration.toString()??""),
                                      SizedBox(height: 20,),
                                      Text(video?.video?.title??"",style: TextStyle(fontSize: 20),),
                                      SizedBox(height: 20,),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: video?.mixList?.length??0,
                                          separatorBuilder: (context,index){
                                            return SizedBox(height: 10,);
                                          },
                                          itemBuilder: (context, index) {

                                            String title = "${video!.video!.title}_${video!.mixList![index].qualityLabel}";

                                            return Row(
                                              children: [
                                                Obx(() {
                                                    return SizedBox(
                                                      width: 80,
                                                      child: ElevatedButton(onPressed: () async{
                                                        if(_dataController.downloadingNow[title+"${video!.mixList![index].container.name}"+"${video!.mixList[index].size.totalMegaBytes}"+"commonmix"]==true){

                                                        }else{
                                                          try{
                                                            await dataController.downloadCommon(title: title!, streamInfo: video!.mixList![index], type: "commonmix");
                                                            dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                          }catch(e){
                                                            logger.e(e);
                                                          }finally{

                                                          }
                                                        }

                                                      }, child:_dataController.downloadingNow[title+"${video!.mixList![index].container.name}"+"${video!.mixList[index].size.totalMegaBytes}"+"commonmix"]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download)),
                                                    );
                                                  }
                                                ),
                                                SizedBox(width: 10,),
                                                Text("(${video!.mixList![index].qualityLabel} , ${video!.mixList![index].container.name} ,${video!.mixList![index].size.totalMegaBytes.toStringAsFixed(2)} MB)"),
                                                SizedBox(width: 10,),
                                                Obx(() {
                                                  return _dataController.downloadProgressMap[title+"${video!.mixList![index].container.name}"+"${video!.mixList[index].size.totalMegaBytes}"+"commonmix"]==null
                                                      ?SizedBox()
                                                      :_dataController.downloadProgressMap[title+"${video!.mixList![index].container.name}"+"${video!.mixList[index].size.totalMegaBytes}"+"commonmix"]==1.0
                                                      ?GestureDetector(onTap: (){
                                                    dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                  }, child: Text("다운로드 완료",style: TextStyle(color: Colors.greenAccent),))
                                                      :SizedBox(
                                                    width: 100,
                                                    child: LinearProgressIndicator(
                                                      value: _dataController.downloadProgressMap[title+"${video!.mixList![index].container.name}"+"${video!.mixList[index].size.totalMegaBytes}"+"commonmix"],
                                                      minHeight: 10.0, // 높이 설정
                                                      backgroundColor: Colors.grey[300],
                                                      color: Colors.blue,
                                                    ),
                                                  );

                                                })
                                                // Text("${}%")
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),


                            ],
                          ),
                          SizedBox(height: 20,),
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
                                        SnackBar(content: Text('Copied to Clipboard')),
                                      );
                                    }

                                  },
                                  child: Icon(Icons.copy)),
                            ],
                          ),
                          Container(
                            height: 150,
                            child: SingleChildScrollView(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${video?.caption??"캡션없음"}"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(

                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("<비디오만 다운로드>"),
                                      SizedBox(height: 10,),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: video!.videoOnlyList.length,
                                          separatorBuilder: (context,index){
                                            return SizedBox(height: 10,);
                                          },
                                          itemBuilder: (context, index) {
                                            String title = "${video!.video!.title}_${video!.videoOnlyList![index].qualityLabel}";
                                            return Row(
                                              children: [
                                                Obx(() {
                                              return SizedBox(
                                                width: 80,
                                                child: ElevatedButton(onPressed: () async{
                                                  if(_dataController.downloadingNow[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"]==true){

                                                  }else{
                                                    try{
                                                      await dataController.downloadCommon(title: title!, streamInfo: video!.videoOnlyList![index], type: "videoonly");
                                                      dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                    }catch(e){
                                                      logger.e(e);
                                                    }finally{

                                                    }
                                                  }

                                                }, child:_dataController.downloadingNow[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download)),
                                              );
                                            }),


                                                SizedBox(width: 10,),
                                                Text("(${video!.videoOnlyList[index].qualityLabel} , ${video!.videoOnlyList[index].container.name} ,${video!.videoOnlyList[index].size.totalMegaBytes.toStringAsFixed(2)} MB)"),
                                                SizedBox(width: 10,),
                                  
                                                Obx(() {
                                                  return _dataController.downloadProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"]==null
                                                      ?SizedBox()
                                                      :_dataController.downloadProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"]==1.0
                                                      ?GestureDetector(onTap: (){
                                                    dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                  }, child: Text("다운로드 완료",style: TextStyle(color: Colors.greenAccent),))
                                                      :SizedBox(
                                                    width: 100,
                                                    child: LinearProgressIndicator(
                                                      value: _dataController.downloadProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"],
                                                      minHeight: 10.0, // 높이 설정
                                                      backgroundColor: Colors.grey[300],
                                                      color: Colors.blue,
                                                    ),
                                                  );
                                  
                                                })
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("<오디오만 다운로드>"),
                                      SizedBox(height: 10,),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: video!.audioOnlyList.length,
                                          separatorBuilder: (context,index){
                                            return SizedBox(height: 10,);
                                          },
                                          itemBuilder: (context, index) {
                                            String title = "${video!.video!.title}_${video!.audioOnlyList![index].qualityLabel}";
                                            return Row(
                                              children: [
                                                Obx(() {
                                                  return SizedBox(
                                                    width: 80,
                                                    child: ElevatedButton(onPressed: () async{
                                                      if(_dataController.downloadingNow[title+"${video!.audioOnlyList![index].container.name}"+"${video!.audioOnlyList[index].size.totalMegaBytes}"+"audioonly"]==true){

                                                      }else{
                                                        try{
                                                          await dataController.downloadCommon(title: title!, streamInfo: video!.audioOnlyList![index], type: "audioonly");
                                                          dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                        }catch(e){
                                                          logger.e(e);
                                                        }finally{

                                                        }
                                                      }

                                                    }, child:_dataController.downloadingNow[title+"${video!.audioOnlyList![index].container.name}"+"${video!.audioOnlyList[index].size.totalMegaBytes}"+"audioonly"]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download)),
                                                  );
                                                }),

                                                SizedBox(width: 10,),
                                                Text("(${video!.audioOnlyList[index].qualityLabel} , ${video!.audioOnlyList[index].container.name} ,${video!.audioOnlyList[index].size.totalMegaBytes.toStringAsFixed(2)} MB)"),

                                                SizedBox(width: 10,),

                                                Obx(() {
                                                  return _dataController.downloadProgressMap[title+"${video!.audioOnlyList![index].container.name}"+"${video!.audioOnlyList[index].size.totalMegaBytes}"+"audioonly"]==null
                                                      ?SizedBox()
                                                      :_dataController.downloadProgressMap[title+"${video!.audioOnlyList![index].container.name}"+"${video!.audioOnlyList[index].size.totalMegaBytes}"+"audioonly"]==1.0
                                                      ?GestureDetector(onTap: (){
                                                    dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                  }, child: Text("다운로드 완료",style: TextStyle(color: Colors.orange),))
                                                      :SizedBox(
                                                    width: 100,
                                                    child: LinearProgressIndicator(
                                                      value: _dataController.downloadProgressMap[title+"${video!.audioOnlyList![index].container.name}"+"${video!.audioOnlyList[index].size.totalMegaBytes}"+"audioonly"],
                                                      minHeight: 10.0, // 높이 설정
                                                      backgroundColor: Colors.grey[300],
                                                      color: Colors.orange,
                                                    ),
                                                  );

                                                })
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(

                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("<비디오+오디오>"),
                                      SizedBox(height: 10,),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: video!.videoOnlyList.length,
                                          separatorBuilder: (context,index){
                                            return video!.videoOnlyList[index].container.name=="mp4"?SizedBox(height: 10,):SizedBox();
                                          },
                                          itemBuilder: (context, index) {
                                            String title = "${video!.video!.title}_${video!.videoOnlyList![index].qualityLabel}";
                                            return video!.videoOnlyList[index].container.name=="mp4"?Row(
                                              children: [

                                                Obx(() {
                                                  return SizedBox(
                                                    width: 80,
                                                    child: ElevatedButton(onPressed: () async{
                                                      if(_dataController.downloadingNow[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"mix"]==true){

                                                      }else{
                                                        try{
                                                          await dataController.downloadMerge(title: title!, streamInfoVideo: video!.videoOnlyList![index], streamInfoAudio: video!.audioOnlyList!.first);
                                                          dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                        }catch(e){
                                                          logger.e(e);
                                                        }finally{

                                                        }
                                                      }

                                                    }, child:_dataController.downloadingNow[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"mix"]==true?SizedBox(width:10,height: 10,child: CircularProgressIndicator()): Icon(Icons.download)),
                                                  );
                                                }),



                                                SizedBox(width: 10,),
                                                Text("(${video!.videoOnlyList[index].qualityLabel} , ${video!.videoOnlyList[index].container.name} ,${video!.videoOnlyList[index].size.totalMegaBytes.toStringAsFixed(2)} MB)"),
                                                SizedBox(width: 10,),
                                                Stack(
                                                  children: [
                                                    Obx(() {
                                                      return _dataController.mergeProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"]==null
                                                          ?SizedBox()
                                                          :_dataController.mergeProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"]==1.0
                                                          ?SizedBox()
                                                          :SizedBox(
                                                        width: 100,
                                                        child: LinearProgressIndicator(
                                                          value: _dataController.mergeProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"videoonly"],
                                                          minHeight: 10.0, // 높이 설정
                                                          backgroundColor: Colors.grey[300],
                                                          color: Colors.blue,
                                                        ),
                                                      );

                                                    }),
                                                    Obx(() {
                                                      return _dataController.mergeProgressMap[title+"${video!.audioOnlyList!.first.container.name}"+"${video!.audioOnlyList!.first.size.totalMegaBytes}"+"audioonly"]==null
                                                          ?SizedBox()
                                                          :_dataController.mergeProgressMap[title+"${video!.audioOnlyList!.first.container.name}"+"${video!.audioOnlyList!.first.size.totalMegaBytes}"+"audioonly"]==1.0
                                                          ?SizedBox()
                                                          :SizedBox(
                                                        width: 100,
                                                        child: LinearProgressIndicator(
                                                          value: _dataController.mergeProgressMap[title+"${video!.audioOnlyList!.first.container.name}"+"${video!.audioOnlyList!.first.size.totalMegaBytes}"+"audioonly"],
                                                          minHeight: 10.0, // 높이 설정
                                                          backgroundColor: Colors.grey[300],
                                                          color: Colors.orange,
                                                        ),
                                                      );

                                                    }),
                                                    Obx(() {
                                                      return _dataController.mergeProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"mix"]==null
                                                          ?SizedBox()
                                                          :_dataController.mergeProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"mix"]==1.0
                                                          ?GestureDetector(onTap: (){
                                                        dataController.openFinder(dataController.appDocumentsDir!.path!);
                                                      }, child: Text("다운로드 완료",style: TextStyle(color: Colors.greenAccent),))
                                                          :SizedBox(
                                                        width: 100,
                                                        child: LinearProgressIndicator(
                                                          value: _dataController.mergeProgressMap[title+"${video!.videoOnlyList![index].container.name}"+"${video!.videoOnlyList[index].size.totalMegaBytes}"+"mix"],
                                                          minHeight: 10.0, // 높이 설정
                                                          backgroundColor: Colors.grey[300],
                                                          color: Colors.pinkAccent,
                                                        ),
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),





                ],
              ),
            ),
            // if(isLoading)
            // Center(
            //
            //   child: Container(
            //    width: 5000,
            //     height: 5000,
            //     color: Colors.black.withOpacity(0.5),
            //     child:  Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         if(currentDownLoadType==0)
            //         Stack(
            //           alignment: Alignment.center,
            //           children: [
            //             SizedBox(
            //               width: 200,
            //               height: 200,
            //               child: CircularProgressIndicator(
            //                 value: videoProgress,// process를 0.0 ~ 1.0으로 변환하여 사용
            //                 strokeWidth: 20.0,
            //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            //                 backgroundColor: Colors.grey[300],
            //               ),
            //             ),
            //             Text(
            //               '${(videoProgress*100).toStringAsFixed(1)}%', // 중앙에 표시될 텍스트
            //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //             ),
            //           ],
            //         ),
            //         if(currentDownLoadType==1)
            //           Stack(
            //             alignment: Alignment.center,
            //             children: [
            //               SizedBox(
            //                 width: 200,
            //                 height: 200,
            //                 child: CircularProgressIndicator(
            //                   value: audioProgress,// process를 0.0 ~ 1.0으로 변환하여 사용
            //                   strokeWidth: 20.0,
            //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            //                   backgroundColor: Colors.grey[300],
            //                 ),
            //               ),
            //               Text(
            //                 '${(audioProgress*100).toStringAsFixed(1)}%', // 중앙에 표시될 텍스트
            //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //               ),
            //             ],
            //           ),
            //         if(currentDownLoadType==2)
            //           Stack(
            //             alignment: Alignment.center,
            //             children: [
            //               SizedBox(
            //                 width: 200,
            //                 height: 200,
            //                 child: CircularProgressIndicator(
            //                   strokeWidth: 20.0,
            //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            //                   backgroundColor: Colors.grey[300],
            //                 ),
            //               ),
            //               Text(
            //                 'merge중', // 중앙에 표시될 텍스트
            //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //               ),
            //             ],
            //           ),
            //       ],
            //     ),
            //   ),
            // ),
            // if(isSearcing)
            //   Center(
            //
            //     child: Container(
            //       width: 5000,
            //       height: 5000,
            //       color: Colors.black.withOpacity(0.5),
            //       child:  Stack(
            //         alignment: Alignment.center,
            //         children: [
            //           SizedBox(
            //             width: 200,
            //             height: 200,
            //             child: CircularProgressIndicator(
            //               strokeWidth: 20.0,
            //               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            //               backgroundColor: Colors.grey[300],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   )

          ],
        );
      }
    );
  }
}

