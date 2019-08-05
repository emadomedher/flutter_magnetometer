import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Singleton providing access to magnetometer data from native platform code
///
/// To use just call [listen] or other supported [Stream] methods on [FlutterMagnetometer.events]
class FlutterMagnetometer {
  /// Singleton intialization
  static final FlutterMagnetometer _instance = FlutterMagnetometer._();

  static const EventChannel _eChannel =
      EventChannel("flutter_magnetometer/magnetometer-events");

  static Stream<MagnetometerData> _streamMagnetometer;

  /// Gets a stream of magnetometer values along the phones's coordinate system in µT (microtesla).
  /// Axes named following Android conventions (z being orthogonal to the screen plane,
  /// y going out of the top and x going out of the right of your device)
  /// https://developer.android.com/images/axis_device.png
  static Stream<MagnetometerData> get events {
    if (_streamMagnetometer == null) {
      _streamMagnetometer = _eChannel
          .receiveBroadcastStream()
          .map<MagnetometerData>(
              (dynamic data) => _listToMagnetometerData(data.cast<double>()));
    }
    return _streamMagnetometer;
  }

  factory FlutterMagnetometer() {
    return _instance;
  }

  FlutterMagnetometer._();

  static MagnetometerData _listToMagnetometerData(List<double> list) =>
      MagnetometerData(list[0], list[1], list[2]);
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
