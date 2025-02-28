
import 'web_common_platform_interface.dart';

class WebCommon {
  Future<String?> getPlatformVersion() {
    return WebCommonPlatform.instance.getPlatformVersion();
  }
}
