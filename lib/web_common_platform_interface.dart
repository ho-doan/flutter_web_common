import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'web_common_method_channel.dart';

abstract class WebCommonPlatform extends PlatformInterface {
  /// Constructs a WebCommonPlatform.
  WebCommonPlatform() : super(token: _token);

  static final Object _token = Object();

  static WebCommonPlatform _instance = MethodChannelWebCommon();

  /// The default instance of [WebCommonPlatform] to use.
  ///
  /// Defaults to [MethodChannelWebCommon].
  static WebCommonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WebCommonPlatform] when
  /// they register themselves.
  static set instance(WebCommonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
