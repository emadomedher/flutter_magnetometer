import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_magnetometer/flutter_magnetometer.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_magnetometer');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return MagnetometerData(5.0, 10.0, 15.0);
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  /// Tests [FlutterMagnetometer.getMagnetometerData] and [MagnetometerData]'s String representatiomn
  test('getMagnetometerData', () async {
    final MagnetometerData testData = await FlutterMagnetometer.getMagnetometerData();
    print(testData.toStringDeep());
    expect(testData, MagnetometerData(5.0, 10.0, 15.0));
    expect(testData.toStringDeep(), '{x: 5.0, y: 10.0, z: 15.0}');
  });
}
