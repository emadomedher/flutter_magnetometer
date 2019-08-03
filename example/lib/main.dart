import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
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

  /// assign listener and start setting real data over [_magnetometerData]
  @override
  void initState() {
    super.initState();
    _magnetometerListener = FlutterMagnetometer.events
        .listen((MagnetometerData data) => setState(() => _magnetometerData = data));
  }

  @override
  void dispose() {
    _magnetometerListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double atan2 = math.atan2(_magnetometerData.y, _magnetometerData.x);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Magnetometer Example'),
      ),
      body: ListView(
        semanticChildCount: 3,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Transform.rotate(
                // calculate the direction we're heading in degrees, then convert to radian
                angle: math.pi / 2 - atan2,
                child: Image.asset('assets/compass.webp'),
              ),
            ),
          ),
          Text('Raw microtesla values: \n: ${_magnetometerData.toStringDeep()}'),
          Text('atan2 result:\n $atan2'),
        ],
      ),
    );
  }
}
