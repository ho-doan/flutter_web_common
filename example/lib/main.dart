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

class _MyAppState extends State<MyApp> {
  final PageController _controller = PageController();

  final controllers = [
    for (int i = 0; i < 50; i++)
      if (i % 2 != 0) VideoController() else null,
  ];

  @override
  Widget build(BuildContext context) {
    log('rebuild');
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(3.rem),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: const AppBarContent(),
          ),
        ),
        body: WebSmoothScroll(
          scrollAnimationLength: 800,
          scrollSpeed: 1.5,
          controller: _controller,
          child: ResponsiveListView(
            controller: _controller,
            sm: 1,
            md: 2,
            $2xl: 3,
            children: [
              for (int i = 0; i < 50; i++)
                if (i % 2 == 0)
                  Container(
                    height: 100,
                    color: Colors.primaries[i % Colors.primaries.length],
                  )
                else
                  SizedBox(
                    height: 100,
                    child: PageView.builder(
                      key: ValueKey('page-view-$i'),
                      // controller: _controller,
                      itemCount: 4,
                      itemBuilder: (_, itemIndex) {
                        return Center(
                          child: VideoWidget(
                            controller: controllers[i],
                            key: ValueKey('page-video-view-$i-$itemIndex'),
                            currentTime: 10,
                            url:
                                'https://aliseyedi01.github.io/Video-Player-TailwindCss/assets/Big-Buck-Bunny.mp4',
                          ),
                        );
                      },
                      scrollDirection: Axis.vertical,
                      // physics: const NeverScrollableScrollPhysics(),
                    ),
                  )
            ],
          ),
          // child: PageView.builder(
          //   controller: _controller,
          //   itemCount: 4,
          //   itemBuilder: (_, itemIndex) {
          //     return const Center(
          //       child: VideoWidget(
          //         currentTime: 10,
          //         url:
          //             'https://aliseyedi01.github.io/Video-Player-TailwindCss/assets/Big-Buck-Bunny.mp4',
          //       ),
          //     );
          //   },
          //   scrollDirection: Axis.vertical,
          //   physics: const NeverScrollableScrollPhysics(),
          // ),
        ),
      ),
      builder: (context, child) {
        return PointerWidget(child: child!);
      },
    );
  }
}

final _menus = [
  'About',
  'Business',
  'News',
  'Contact',
];

class AppBarContent extends StatefulWidget {
  const AppBarContent({super.key});

  @override
  State<AppBarContent> createState() => _AppBarContentState();
}

class _AppBarContentState extends State<AppBarContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              ResponsiveWidget(
                hidden: ResponsiveType.xsm,
                child: Text(
                  'PreferredSize Sample',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 1.23.rem,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              for (final item in _menus)
                ResponsiveWidget(
                  hidden: ResponsiveType.md,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      item.toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 1.rem,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.search, size: 20),
                color: Colors.blue[900],
                iconSize: 2.rem,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.menu_open_sharp, size: 20),
                color: Colors.blue[900],
                iconSize: 2.rem,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
