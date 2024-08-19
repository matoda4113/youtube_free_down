import 'package:flutter/material.dart';

import '../global/global.dart';

///HistoryScreen
///담당자 : ---

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  @override
  void initState() {
    super.initState();
    logger.i("HistoryScreen");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("HistoryScreen"),
    );
  }
}
