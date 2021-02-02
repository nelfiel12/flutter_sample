import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

import 'Log.dart';

class CameraSample extends StatefulWidget {
  
  
  
  @override
  CameraSampleState createState() {
    // TODO: implement createState
    return CameraSampleState();
  }
}

class CameraSampleState extends State<CameraSample> {
  CameraDescription _camera;
  CameraController _controller;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  Future<bool> _initCamera() async {

    CameraDescription camera = await _getCamera();

    _controller = CameraController(camera, ResolutionPreset.medium);

    await _controller.initialize();
    await _controller.setFlashMode(FlashMode.always);
    return true;
  }

  Future<dynamic> _getCamera() async {
    List<CameraDescription> cameras = await availableCameras();

    return cameras.first;
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: _initCamera(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return CameraPlatform.instance.buildPreview(_controller.cameraId);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),

          Container(
            height: 100,
            width: 400,
            color: Color.fromARGB(127, 200, 200, 200),
            child:
            Row(
              children: [
                ElevatedButton(onPressed: () async {
                  await _controller.setFlashMode(FlashMode.torch);
                }, child: Text('on')),
                ElevatedButton(onPressed: () async {
                  await _controller.setFlashMode(FlashMode.off);
                }, child: Text('off')),
                TextButton(child: Text('test', style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 50)), onPressed: () async {

                  XFile file = await _controller.takePicture();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: file.path)));
                  /*
                  _controller.takePicture().then((value) {
                    debug('takePicture');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: value.path)));
                  });

                   */
                })
              ],
            )
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}