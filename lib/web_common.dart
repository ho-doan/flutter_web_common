import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:js/js.dart';

import 'dart:html' hide Point;

import 'src/models/css_style_declaration.dart';
import 'web_common_platform_interface.dart';

export 'src/widgets/video_widget.dart';
export 'src/widgets/pointer_widget.dart';

class WebCommon {
  static final instance = WebCommon();
  Future<String?> getPlatformVersion() {
    return WebCommonPlatform.instance.getPlatformVersion();
  }
}

enum ResponsiveType {
  /// 640px
  sm,

  /// 768px
  md,

  /// 1024px
  lg,

  /// 1280px
  xl,

  /// 1536px
  $2xl,
}

extension on num {
  ResponsiveType get typeRes {
    ResponsiveType newType;
    if (this < 640) {
      newType = ResponsiveType.sm;
    } else if (this < 768) {
      newType = ResponsiveType.md;
    } else if (this < 1024) {
      newType = ResponsiveType.lg;
    } else if (this < 1280) {
      newType = ResponsiveType.xl;
    } else {
      newType = ResponsiveType.$2xl;
    }
    return newType;
  }
}

class SizeCommon extends ValueNotifier<ResponsiveType> {
  SizeCommon(super.value);
  set size(Size v) {
    ResponsiveType newType = v.width.typeRes;
    if (newType != value) {
      value = newType;
      notifyListeners();
    }
  }
}

mixin WebCommonMixin {
  static late final SizeCommon _sizeCommon;
  static late double _px;

  static final Completer _hasScriptLoaded = Completer<void>();
  static Future<void> _loadJS() async {
    final hasImport = document.querySelector(
        'script[src=\'assets/packages/web_common/assets/common.js\']');
    if (hasImport != null) return;
    final script = ScriptElement()
      ..addEventListener("load", (event) {
        _hasScriptLoaded.complete();
      })
      // ignore: unsafe_html
      ..src = "assets/packages/web_common/assets/common.js";
    document.head!.append(script);

    return _hasScriptLoaded.future;
  }

  static Future<void> initial() async {
    log('initial WebCommonMixin');
    _sizeCommon = SizeCommon((window.innerWidth ?? 0).typeRes);
    await _loadJS();
    final s = _getCommon();
    _px = double.parse(s.fontSize.replaceFirst('px', '')).toDouble();
    window.addEventListener('resize', (_) {
      _sizeCommon.size = Size(
        (window.innerWidth ?? 0).toDouble(),
        (window.innerHeight ?? 0).toDouble(),
      );
    });
  }
}

extension NumX on num {
  num get rem => this * WebCommonMixin._px;
}

@JS('web_common.getCommon')
external CSSStyleDeclaration _getCommon();

abstract class MState<T extends StatefulWidget> extends State<T> {
  SizeCommon get _utils => WebCommonMixin._sizeCommon;

  late ResponsiveType resType;

  void _listen() {
    setState(() {
      resType = _utils.value;
    });
  }

  @override
  void initState() {
    resType = _utils.value;
    _utils.addListener(_listen);
    super.initState();
  }

  @override
  void dispose() {
    _utils.removeListener(_listen);
    super.dispose();
  }
}
