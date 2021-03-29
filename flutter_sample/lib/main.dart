import 'dart:isolate';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/AudioRecord.dart';
import 'package:flutter_sample/CacheImage.dart';
import 'package:flutter_sample/PlatformChannelTest.dart';
import 'package:flutter_sample/ShareTest.dart';
import 'package:flutter_sample/kakaoSample.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';

import 'CameraSample.dart';
import 'Log.dart';
import 'dart:io';

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


  debug('onBackgroundMessage s');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  debug('onBackgroundMessage e');

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


  debug('runApp');
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



  static void _tester(SendPort sendPort) async {
    for(int i=0; i<100100; i++) {
      debug('$i');
    }

    sendPort.send(true);
  }

  List<Uri> images = [];

  TestImage test = TestImage('test');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    test.init();
  }

  @override
  Widget build(BuildContext context) {




    return Scaffold(
      appBar: AppBar(
        title: Text('Sample'),
      ),
      body: Center(
        child: ListView(
          children: [
            StatefulBuilder(builder: (context, setState) {
              return Column(
                children: [
                  Row(
                    children: [
                      TextButton(onPressed: () async {
                        final String path = 'https://picsum.photos/${Random().nextInt(1000) + 100}/${Random().nextInt(1000) + 100}';

                        final String key = path.replaceAll('https://', '').replaceAll('/', '_');


                        setState((){});
                      }, child: Text('add')),
                      TextButton(onPressed: () async {

                        images.clear();

                        for(int i=0; i<200; i++) {
                          final String path = 'https://picsum.photos/${Random().nextInt(30) + 1000}/${Random().nextInt(30) + 1000}';

                          images.add(Uri.tryParse(path));
                        }

                        setState(() {} );


                      }, child: Text('refresh')),
                      TextButton(onPressed: () async {
                        final String path = 'https://picsum.photos/${Random().nextInt(30) + 1000}/${Random().nextInt(30) + 1000}';

                        final String key = path.replaceAll('https://', '').replaceAll('/', '_');
                        File file = await test.put(key, Uri.tryParse(path));

                        int total = await file.length();

                        await GallerySaver.saveImage(file.path, albumName: 'test');

                        return;
                      }, child: Text('test')),
                      TextButton(onPressed: () {

                        test;
                        return;
                      }, child: Text('test1'))
                    ],
                  ),
                  Container(
                    height: 500,
                    child: ListView.builder(
                      itemCount: images?.length,
                      itemBuilder: (context, index) {
                        final Uri uri = images[index];

                        final String key = uri.toString().replaceAll('https://', '').replaceAll('/', '_');

                        return FutureBuilder<File>(
                          future: test.put(key, uri),
                          builder: (context, snapshot) {

                            final File file = snapshot.data;



                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('key: $key'),
                                if(file == null)
                                  Center(child: CircularProgressIndicator())
                                else
                                  Image.file(file, width: 100, height: 100,)
                              ],
                            );
                          },
                        );

                      },
                    )
                  ),
                  TextButton(onPressed: () async {

                    test;



                    setState((){});
                  }, child: Text('1'))
                ],
              );
            },),
            createCard('test', () {
              CacheImage image = CacheImage('https://picsum.photos/2002/3002');

              image.getImage();
            }),
            createCard('isolate', () async {

              ReceivePort _receivePort = ReceivePort();

              await Isolate.spawn<SendPort>(_tester, _receivePort.sendPort);

              await showDialog(context: context, builder: (context) {
                return AlertDialog(
                  content: FutureBuilder(
                    future: _receivePort.first,
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        int a = 0;
                        debug('complete');
                      } else {

                      }

                      return Center(
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            Text('${snapshot.hasData} ${snapshot.hasError}')
                          ],
                        ),
                      );
                    },
                  ),
                );
              },);

              return;
            }),
            Stack(
              children: [
                Image.network('https://picsum.photos/555/555'),
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.srcOut,
                    ), // This one will create the magic
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            backgroundBlendMode: BlendMode.dstOut,
                          ), // This one will handle background + difference out
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),

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
