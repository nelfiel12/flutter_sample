import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ShareTestWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShareTestWidgetState();
  }
}

class ShareTestWidgetState extends State<ShareTestWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Share'),),
      body: ListView(
        children: [
          Card(
            child: ListTile(title: Text('share'), onTap: () async {
              Share.share('test', subject: 'test subject');
            },),
          ),
        ],
      ),
    );
  }
}