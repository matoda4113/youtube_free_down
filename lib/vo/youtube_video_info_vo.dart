

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeVideoInfoVo {
  Video? video;
  String? caption; // 자막

  List<MuxedStreamInfo> mixList;
  List<VideoOnlyStreamInfo> videoOnlyList;
  List<AudioOnlyStreamInfo> audioOnlyList;

  YoutubeVideoInfoVo({
    this.video,
    this.caption,
    List<MuxedStreamInfo>? mixList,
    List<VideoOnlyStreamInfo>? videoOnlyList,
    List<AudioOnlyStreamInfo>? audioOnlyList,
  })  : mixList = mixList ?? [],
        videoOnlyList = videoOnlyList ?? [],
        audioOnlyList = audioOnlyList ?? [];
}
