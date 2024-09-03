
import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../global/global.dart';
import '../vo/youtube_video_info_vo.dart';



///DataController
///담당자 : saran

class DataController extends GetxController {

  YoutubeExplode yt = YoutubeExplode();


  Directory? tempDir;
  Directory? appDocumentsDir;


  RxMap<String,double> downloadProgressMap = <String, double>{}.obs;
  RxMap<String,double> mergeProgressMap = <String, double>{}.obs;
  RxMap<String,bool> downloadingNow = <String, bool>{}.obs;


  //다운로드 경로 설정
  Future<void> getPath() async{
    tempDir = await getTemporaryDirectory();
    appDocumentsDir = await getApplicationDocumentsDirectory();

    update();
  }


  //파일삭제
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  //유튜브 정보 받아오기
  Future<YoutubeVideoInfoVo> getYoutubeInfo(String url) async{
    downloadProgressMap.clear();
    mergeProgressMap.clear();

    YoutubeVideoInfoVo youtubeVideoInfoVo = YoutubeVideoInfoVo();
    String videoId = extractVideoId(url);
    logger.i(videoId);

    try{
      //비디오 정보
      youtubeVideoInfoVo.video = await yt.videos.get(videoId);

      //자막정보
      ClosedCaptionManifest? trackManifest = await yt.videos.closedCaptions.getManifest(videoId);


      if(trackManifest !=null && trackManifest.tracks.isNotEmpty){
        List<ClosedCaptionTrackInfo>? tracks = trackManifest.tracks.where((element) => element.format.formatCode=='srv1').toList();
        ClosedCaptionTrackInfo trackInfo = tracks!.where((element) => element.isAutoGenerated == true).first;
        ClosedCaptionTrack d = await yt.videos.closedCaptions.get(trackInfo);
        String tmpCaption = "";
        d.captions.forEach((c){
          tmpCaption = tmpCaption+"\n"+c.text;
        });
        //자막삽입
        youtubeVideoInfoVo.caption = tmpCaption;
      }

      StreamManifest streamManifest = await yt.videos.streamsClient.getManifest(extractVideoId(videoId));
      youtubeVideoInfoVo.mixList = streamManifest.muxed.toList(); // 혼합
      youtubeVideoInfoVo.videoOnlyList = streamManifest.videoOnly.toList(); // 비디오만
      youtubeVideoInfoVo.audioOnlyList = streamManifest.audioOnly.toList(); // 오디오만

    return youtubeVideoInfoVo;
    }catch(e){
      logger.w(e);
      throw Exception(e);
    }

  }

  //일반 다운로드 ( 혼합비디오 , 오디오 , 비디오온리, 오디오온리 )
  Future<String> downloadCommon({required String title,required StreamInfo streamInfo, required String type , required String mediaKey}) async {

    //제목공백제거
    String t1 = title.replaceAll(RegExp(r'\s+'), '');
    //공백및 안되는 문자 제거후 제목
    String fixedTitle = t1.replaceAll(RegExp(r'[\/:*?"<>|\\]'), '_');
    String mediaFilePath ="";
    //////비디오 or 오디오
    try{
      // Completer 생성
      Completer<String> completer = Completer();
      if (streamInfo != null) {

        mediaFilePath = '${appDocumentsDir!.path}/"${fixedTitle}_${type}.${streamInfo.container.name}';
        Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfo);
        IOSink fileStream = File(mediaFilePath).openWrite();
        var totalBytes = streamInfo.size.totalBytes;
        num receivedBytes = 0;
        // 초기 진행률 설정
        downloadProgressMap[mediaKey] = 0.0;
        downloadingNow[mediaKey] = true;

        stream.listen(
              (data) {
                // print('onData: $data');
            fileStream.add(data);
            receivedBytes += data.length;
            //진행률 업데이트
            downloadProgressMap[mediaKey] = receivedBytes / totalBytes;

          }, onDone: () async {
            await fileStream.flush();
            await fileStream.close();
            // // 다운로드 완료시 진행률 1.0으로 설정
            downloadProgressMap[mediaKey] = 1.0;
            downloadingNow[mediaKey] = false;
            completer.complete(mediaFilePath);
          },
          onError: (e) {
            logger.e('Error: $e');
            downloadProgressMap.remove(mediaKey);  // 에러 발생 시 항목 제거
            downloadingNow[mediaKey] = false;
            completer.completeError(e);
          },
          cancelOnError: true,
        );
      }

      return completer.future;
    }catch(e){
      throw Exception(e);
    }

  }




  Future<String> downloadMerge({required String title,required StreamInfo streamInfoVideo,required StreamInfo streamInfoAudio , required String mediaKeyVideo , required String mediaKeyAudio}) async {




    //제목공백제거
    String t1 = title.replaceAll(RegExp(r'\s+'), '');

    //공백및 안되는 문자 제거후 제목
    String t2 = t1.replaceAll(RegExp(r'[\/:*?"<>|\\]'), '_');
    String fixedTitle = t2.replaceAll(RegExp(r"['|\\]"), '_');

    String videoFilePathTmp ="";
    String audioFilePathTmp ="";
    String mergeFilePath ='${appDocumentsDir!.path}/${fixedTitle}_mix.${streamInfoVideo.container.name}';

    try{

      // Completer 생성
      Completer<void> videoCompleter = Completer<void>();
      Completer<void> audioCompleter = Completer<void>();
      downloadingNow[mediaKeyVideo+"mix"] = true;
      //////비디오
      if (streamInfoVideo != null) {


        videoFilePathTmp = '${tempDir!.path}/${fixedTitle}_video.${streamInfoVideo.container.name}';
        Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfoVideo);
        IOSink fileStream = File(videoFilePathTmp).openWrite();
        var totalBytes = streamInfoVideo.size.totalBytes;
        num receivedBytes = 0;
        // 초기 진행률 설정
        mergeProgressMap[mediaKeyVideo] = 0.0;

        stream.listen(
              (data) {
            fileStream.add(data);
            receivedBytes += data.length;
            // 진행률 업데이트
            mergeProgressMap[mediaKeyVideo] = receivedBytes / totalBytes;
          },
          onDone: () async {

            await fileStream.flush();
            await fileStream.close();

            // 다운로드 완료시 진행률 1.0으로 설정
            mergeProgressMap[mediaKeyVideo] = 1.0;
            videoCompleter.complete();
          },
          onError: (e) {
            logger.e('Error: $e');
            mergeProgressMap.remove(mediaKeyVideo);  // 에러 발생 시 항목 제거
            videoCompleter.completeError(e);
          },
          cancelOnError: true,
        );
      }

      //////오디오
      if (streamInfoAudio != null) {
        audioFilePathTmp = '${tempDir!.path}/${fixedTitle}_audio.${streamInfoAudio.container.name}';
        Stream<List<int>> stream = yt.videos.streamsClient.get(streamInfoAudio);
        IOSink fileStream = File(audioFilePathTmp).openWrite();
        var totalBytes = streamInfoVideo.size.totalBytes;
        num receivedBytes = 0;
        // 초기 진행률 설정
        mergeProgressMap[mediaKeyAudio] = 0.0;
        stream.listen(
              (data) {
            fileStream.add(data);
            receivedBytes += data.length;
            // 진행률 업데이트
            mergeProgressMap[mediaKeyAudio] = receivedBytes / totalBytes;
          },
          onDone: () async {
            await fileStream.flush();
            await fileStream.close();
            // 다운로드 완료시 진행률 1.0으로 설정
            mergeProgressMap[mediaKeyAudio] = 1.0;
            audioCompleter.complete();
          },
          onError: (e) {
            logger.e('Error: $e');
            downloadProgressMap.remove(mediaKeyAudio);  // 에러 발생 시 항목 제거
            audioCompleter.completeError(e);
          },
          cancelOnError: true,
        );
      }


      // 비디오와 오디오가 모두 완료될 때까지 대기
      await Future.wait([videoCompleter.future, audioCompleter.future]);

      ///////// 비디오와 오디오 합치기
      final command = '-y -i $videoFilePathTmp -i $audioFilePathTmp -c:v copy -c:a aac -strict experimental ${mergeFilePath}';


      double totalDurationSeconds = await getVideoDuration(videoFilePathTmp)??1000000.0;
      // 초기 진행률 설정
      downloadProgressMap[mediaKeyVideo+"mix"] = 0.0;
      // 로그 콜백 설정
      FFmpegKitConfig.enableLogCallback((log) async{
        String logMessage = log.getMessage();
        // 진행률을 추출하기 위한 정규식
        final match = RegExp(r'time=(\d+:\d+:\d+\.\d+)').firstMatch(logMessage);
        if (match != null) {
          String timeString = match.group(1)!;
          double currentTimeSeconds = _convertTimeToSeconds(timeString);
          // 진행률 계산
          double progress = currentTimeSeconds / totalDurationSeconds;
          mergeProgressMap[mediaKeyVideo+"mix"] = progress;
        }
      });

      FFmpegSession session =  await FFmpegKit.execute(command);

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        mergeProgressMap[mediaKeyVideo+"mix"] = 1.0;
      } else {
        throw Exception("merge실패");
      }
      downloadingNow[mediaKeyVideo+"mix"] = false;
      return mergeFilePath;
    }catch(e){
      logger.e(e);
      throw Exception(e);
    }




  }


  void openFinder(String path) async{

    Process.run('open', ["${path}"]).then((ProcessResult results) {

    }).catchError((e) {
      logger.e('Error: $e');
    });
  }

  void openRootDir() async{

    Process.run('open', ["${appDocumentsDir!.path}"]).then((ProcessResult results) {

      logger.i(appDocumentsDir!.path);
    }).catchError((e) {
      logger.e('Error: $e');
    });
  }






  // 로그에서 추출한 시간을 초 단위로 변환
  double _convertTimeToSeconds(String timeString) {
    final parts = timeString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = double.parse(parts[2]);
    return hours * 3600 + minutes * 60 + seconds;
  }


  Future<double?> getVideoDuration(String videoFilePath) async {
    // FFprobe로 비디오의 메타데이터를 분석
    final session = await FFprobeKit.getMediaInformation(videoFilePath);

    final info = await session.getMediaInformation();
    if (info != null) {
      // 비디오의 듀레이션 (초 단위)
      String? durationInSeconds = info.getDuration();

      return double.parse(durationInSeconds!);
    }

    // 오류 발생 시 null 반환
    return null;
  }

}