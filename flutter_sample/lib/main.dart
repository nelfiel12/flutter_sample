import 'package:flutter/material.dart';
import 'package:flutter_sample/kakaoSample.dart';
import 'package:kakao_flutter_sdk/all.dart';

import 'CameraSample.dart';

void main() {
  KakaoContext.clientId = "e6850a095ecbacb2911f82b1fcca08c2";

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample'),
      ),
      body: Center(
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: Text('Kakao sample'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => KakaoSample(),));
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Camera sample'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CameraSample(),));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
