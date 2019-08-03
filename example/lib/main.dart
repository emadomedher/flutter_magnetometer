import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_magnetometer/flutter_magnetometer.dart';

void main() => runApp(MagnetometerExampleApp());

class MagnetometerExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: CompassPage(),
    );
  }
}

class CompassPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  MagnetometerData _magnetometerData = MagnetometerData(0.0, 0.0, 0.0);

  StreamSubscription _magnetometerListener;

  @override
  void initState() {
    super.initState();
    print('Starting with data ${_magnetometerData.toStringDeep()}');
    initPlatformState();

    _magnetometerListener = FlutterMagnetometer.events.listen((MagnetometerData data) => _magnetometerData = data);
  }

  @override
  void dispose() {
    _magnetometerListener.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    MagnetometerData magnetometerData;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      magnetometerData = await FlutterMagnetometer.getMagnetometerData();
      print('New data ${magnetometerData.toStringDeep()}');
    } on PlatformException catch (e) {
      print(e);
      magnetometerData = MagnetometerData(0.0, 0.0, 0.0);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => _magnetometerData = magnetometerData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Magnetometer Example'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(_magnetometerData.toStringDeep()),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Transform.rotate(
                // calculate the direction we're heading in degrees, then convert to radian
                angle: math.atan2(_magnetometerData.y, _magnetometerData.x) * 180 / math.pi,
                child: Image.asset('assets/compass.webp'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
