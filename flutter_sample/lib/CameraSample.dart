import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

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
            child: Center( child: Text('test', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50), ),) ,
          ),
        ],
      ),
    );
  }
}