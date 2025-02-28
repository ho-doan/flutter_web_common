import 'package:flutter_test/flutter_test.dart';
import 'package:web_common/web_common.dart';
import 'package:web_common/web_common_platform_interface.dart';
import 'package:web_common/web_common_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWebCommonPlatform
    with MockPlatformInterfaceMixin
    implements WebCommonPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WebCommonPlatform initialPlatform = WebCommonPlatform.instance;

  test('$MethodChannelWebCommon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWebCommon>());
  });

  test('getPlatformVersion', () async {
    WebCommon webCommonPlugin = WebCommon();
    MockWebCommonPlatform fakePlatform = MockWebCommonPlatform();
    WebCommonPlatform.instance = fakePlatform;

    expect(await webCommonPlugin.getPlatformVersion(), '42');
  });
}
