import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformChannelTest extends StatefulWidget {
  @override
  PlatformChannelTestState createState() {
    // TODO: implement createState
    return PlatformChannelTestState();
  }
}

class PlatformChannelTestState extends State<PlatformChannelTest> {
  static const platform = const MethodChannel('samples.flutter.dev/battery');

  String _batteryLevel;

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          child: Text('Get Battery Level'),
          onPressed: _getBatteryLevel,
        ),
        _batteryLevel != null ? Text(_batteryLevel) : Text('null')
      ],
    ),
    ),
    );
  }
}