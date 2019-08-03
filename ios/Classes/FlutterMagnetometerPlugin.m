#import "FlutterMagnetometerPlugin.h"
#import <flutter_magnetometer/flutter_magnetometer-Swift.h>

@implementation FlutterMagnetometerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMagnetometerPlugin registerWithRegistrar:registrar];
}
@end
