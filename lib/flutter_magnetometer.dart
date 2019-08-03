import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterMagnetometer {
  /// Singleton intialization
  static final FlutterMagnetometer _instance = FlutterMagnetometer._();

  factory FlutterMagnetometer() {
    return _instance;
  }

  FlutterMagnetometer._();

  static const MethodChannel _mChannel = const MethodChannel('flutter_magnetometer');
  static const EventChannel _eChannel =
      const EventChannel("flutter_magnetometer/magnetometer-events");

  static Stream<MagnetometerData> _streamMagnetometer;

  /// Gets the magnetometer values along the phones's coordinate system in µT (microtesla).
  /// Axes named following Android conventions (z being orthogonal to the screen plane,
  /// y going out of the top and x going out of the right of your device)
  /// https://developer.android.com/images/axis_device.png
  static Future<MagnetometerData> getMagnetometerData() async {
    final result = await _mChannel.invokeMethod('getMagnetometerData');
    print('from channel ${result.toString()}');

    return MagnetometerData.fromMap(json.decode(json.encode(result)));
  }

  static Stream<MagnetometerData> get events {
    if (_streamMagnetometer == null) {
      _streamMagnetometer = _eChannel.receiveBroadcastStream().map<MagnetometerData>(
          (data) => MagnetometerData.fromMap(json.decode(json.encode(data))));
    }

    return _streamMagnetometer;
  }
}

/// An object representing the data acquired from a magnetometer along the device's coordinate
/// system.
///
/// The attributes are stored as µT (microtesla).
///
/// Use [FlutterMagnetometer]'s methods or streams to create meaningful instances
/// (e.g. [MagnetometerData.getMagnetometerData])
@immutable
class MagnetometerData extends Equatable {
  final double x;
  final double y;
  final double z;

  MagnetometerData(this.x, this.y, this.z);

  factory MagnetometerData.fromMap(Map<String, dynamic> map) =>
      MagnetometerData(map['x'], map['y'], map['z']);

  Map<String, double> toMap() => {'x': x, 'y': y, 'z': z};

  String toStringDeep() => toMap().toString();
}
