import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:js/js.dart';

import 'dart:html' hide Point;

import 'src/models/css_style_declaration.dart';
import 'web_common_platform_interface.dart';
import 'package:collection/collection.dart';

export 'src/widgets/video_widget.dart';
export 'src/widgets/pointer_widget.dart';

class WebCommon {
  static final instance = WebCommon();
  Future<String?> getPlatformVersion() {
    return WebCommonPlatform.instance.getPlatformVersion();
  }
}

enum ResponsiveType {
  /// 320px
  xxs(320),

  /// 480px
  xsm(480),

  /// 640px
  sm(640),

  /// 768px
  md(768),

  /// 1024px
  lg(1024),

  /// 1280px
  xl(1280),

  /// 1536px
  $2xl(1536);

  final int value;

  const ResponsiveType(this.value);
}

extension ResponsiveTypeX on ResponsiveType {
  bool hidden(ResponsiveType type) => value > type.value;

  bool show(ResponsiveType type) => value <= type.value;

  T when<T>({
    T? xxs,
    T? xsm,
    T? sm,
    T? md,
    T? lg,
    T? xl,
    T? $2xl,
    required T orElse,
  }) {
    switch (this) {
      case ResponsiveType.xxs:
        return xxs ?? orElse;
      case ResponsiveType.xsm:
        return xsm ?? xxs ?? orElse;
      case ResponsiveType.sm:
        return sm ?? xsm ?? xxs ?? orElse;
      case ResponsiveType.md:
        return md ?? sm ?? xsm ?? xxs ?? orElse;
      case ResponsiveType.lg:
        return lg ?? md ?? sm ?? xsm ?? xxs ?? orElse;
      case ResponsiveType.xl:
        return xl ?? lg ?? md ?? sm ?? xsm ?? xxs ?? orElse;
      case ResponsiveType.$2xl:
        return $2xl ?? xl ?? lg ?? md ?? sm ?? xsm ?? xxs ?? orElse;
    }
  }
}

extension on num {
  ResponsiveType get typeRes {
    ResponsiveType newType;
    if (this < 320) {
      newType = ResponsiveType.xxs;
    } else if (this < 480) {
      newType = ResponsiveType.xsm;
    } else if (this < 640) {
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
  static final SizeCommon _sizeCommon =
      SizeCommon((window.innerWidth ?? 0).typeRes);
  static double get _px {
    final s = _getCommon();
    return double.parse(s.fontSize.replaceFirst('px', '')).toDouble();
  }

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
    await _loadJS();
    window.addEventListener('resize', (_) {
      _sizeCommon.size = Size(
        (window.innerWidth ?? 0).toDouble(),
        (window.innerHeight ?? 0).toDouble(),
      );
    });
  }
}

extension NumX on num {
  double get rem => this * WebCommonMixin._px;
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

class ResponsiveWidget extends StatefulWidget {
  const ResponsiveWidget({
    super.key,
    this.hidden,
    required this.child,
    this.elseWidget = const SizedBox.shrink(),
  });

  final ResponsiveType? hidden;
  final Widget child;
  final Widget elseWidget;

  @override
  State<ResponsiveWidget> createState() => _ResponsiveWidgetState();
}

class _ResponsiveWidgetState extends MState<ResponsiveWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.hidden != null && !resType.hidden(widget.hidden!)) {
      return widget.elseWidget;
    }
    return widget.child;
  }
}

class ResponsiveListView extends StatefulWidget {
  const ResponsiveListView({
    super.key,
    required this.children,
    this.xxs,
    this.xsm,
    this.sm,
    this.md,
    this.lg,
    this.xl,
    this.$2xl,
    this.controller,
  });
  final List<Widget> children;

  final int? xxs, xsm, sm, md, lg, xl, $2xl;
  final ScrollController? controller;

  @override
  State<ResponsiveListView> createState() => _ResponsiveListViewState();
}

class _ResponsiveListViewState extends MState<ResponsiveListView> {
  final int orElse = 1;

  @override
  Widget build(BuildContext context) {
    final itemRows = resType.when(
      $2xl: widget.$2xl,
      lg: widget.lg,
      md: widget.md,
      sm: widget.sm,
      xl: widget.xl,
      xsm: widget.xsm,
      xxs: widget.xxs,
      orElse: orElse,
    );
    final children = widget.children.slices(itemRows).toList();
    return ListView.builder(
      controller: widget.controller,
      itemCount: children.length,
      itemBuilder: (_, i) {
        final items = List.from(children[i]);
        if (items.length < itemRows) {
          items.add(const SizedBox.shrink());
        }
        return Row(
          children: [
            for (final item in items)
              Expanded(
                child: AnimatedContainer(
                  key: ObjectKey(item),
                  duration: const Duration(milliseconds: 500),
                  child: item,
                ),
              ),
          ],
        );
      },
    );
  }
}
