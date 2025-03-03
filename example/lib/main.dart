import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:web_common/web_common.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await WebCommonMixin.initial();
      runApp(const MyApp());
    },
    (e, s) {
      log(e.toString(), stackTrace: s);
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends MState<MyApp> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    log('rebuild');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: WebSmoothScroll(
          scrollAnimationLength: 800,
          scrollSpeed: 1.5,
          controller: _controller,
          child: PageView.builder(
            controller: _controller,
            itemCount: 4,
            itemBuilder: (_, itemIndex) {
              return const Center(
                child: VideoWidget(
                  url:
                      'https://aliseyedi01.github.io/Video-Player-TailwindCss/assets/Big-Buck-Bunny.mp4#t=20',
                ),
              );
            },
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
