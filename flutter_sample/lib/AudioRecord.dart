import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecord extends StatefulWidget {
  @override
  AudioRecordState createState() {
    // TODO: implement createState
    return AudioRecordState();
  }
}

class AudioRecordState extends State<AudioRecord> {

  FlutterAudioRecorder _recorder;
  Timer _timer;
  String _text = 'null';
  String _text2 = 'null';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();



  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Recording'),),
      body: FutureBuilder(
        future: FlutterAudioRecorder.hasPermissions,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data) {
              return Column(
                children: [
                  Text(_text, style: TextStyle(fontSize: 30, color: Colors.black),),
                  Text(_text2, style: TextStyle(fontSize: 20, color: Colors.black),),

                  Container(
                    height: 500,
                    child: ListView(
                      children: [
                        Card(
                          child: ListTile(
                            title: Text('start'), onTap: () async {
/*
                            List<Directory> list = await getExternalStorageDirectories(type: StorageDirectory.music);

                            for(int i=0; i<list.length; i++) {
                              print(list[i].path);
                            }
*/

                            Directory appDocDir = await getExternalStorageDirectory();
                            print(appDocDir.path);

                            _recorder = FlutterAudioRecorder(appDocDir.path + '/test.mp4', audioFormat: AudioFormat.AAC);
                            await _recorder.initialized;

                            await _recorder.start();

                            _timer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
                              Recording rec = await _recorder.current();
                              setState(() {
                                _text = DateTime.now().toString();
                                _text2 = rec.duration.toString();
                              });
                            });
                          },
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: Text('stop'), onTap: () async {

                            if(_timer != null)
                              _timer.cancel();

                            if(_recorder != null) {


                              await _recorder.stop();
                            }
                          },
                          ),
                        )

                      ],
                    ),
                  )
                ],
              );
            } else {
              return Center(
                child: Text('need permission'),
              );
            }
          } else if(snapshot.hasError) {
            return Center(
              child: Text('hasError'),
            );
          } else {
            return Center(
              child: Text('need permission'),
            );
          }
        },
      ),
    );
  }
}