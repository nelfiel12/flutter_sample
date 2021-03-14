import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/AudioRecord.dart';
import 'package:flutter_sample/PlatformChannelTest.dart';
import 'package:flutter_sample/ShareTest.dart';
import 'package:flutter_sample/kakaoSample.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:firebase_core/firebase_core.dart';

import 'CameraSample.dart';
import 'Log.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  debug("Handling a background message: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  KakaoContext.clientId = "e6850a095ecbacb2911f82b1fcca08c2";


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debug('Got a message whilst in the foreground!');
    debug('Message data: ${message.data}');

    if (message.notification != null) {
      debug('Message also contained a notification: ${message.notification}');
    }
  });



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
            createCard('token', () async {
              String token = await FirebaseMessaging().getToken();
              debug(token);
              return;
            }),
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
            Card(
              child: ListTile(
                title: Text('Audio recording'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AudioRecord(),));
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Platform'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PlatformChannelTest(),));
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Share'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ShareTestWidget(),));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createCard(String title, VoidCallback callback) {
    return
      Card(
        child: ListTile(
          title: Text('$title'),
          onTap: callback
        ),
      );
  }
}
