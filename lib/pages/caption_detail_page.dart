import 'package:flutter/material.dart';

import '../global/global.dart';

///CaptionDetailPage
///담당자 : ---

class CaptionDetailPage extends StatefulWidget {
  const CaptionDetailPage({Key? key}) : super(key: key);

  @override
  State<CaptionDetailPage> createState() => _CaptionDetailPageState();
}

class _CaptionDetailPageState extends State<CaptionDetailPage> {

  @override
  void initState() {
    super.initState();
    logger.i("CaptionDetailPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CaptionDetailPage"),),
      body: Text("CaptionDetailPage"),
    );
  }
}
