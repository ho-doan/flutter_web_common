import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'web_common_platform_interface.dart';

/// An implementation of [WebCommonPlatform] that uses method channels.
class MethodChannelWebCommon extends WebCommonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('web_common');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
