import 'dart:async';
import 'dart:developer';
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:web_common/web_common.dart';

class VideoState extends ChangeNotifier {
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  num _currentTime = 0;

  num get currentTime => _currentTime;
  set currentTime(num v) {
    _currentTime = v;
    notifyListeners();
  }

  final VoidCallback? _play, _pause;
  final ValueChanged<num>? _changeCurrentTime;

  VideoState({
    required VoidCallback? play,
    required VoidCallback? pause,
    required ValueChanged<num>? changeCurrentTime,
    required num currentTime,
  })  : _play = play,
        _pause = pause,
        _currentTime = currentTime,
        _changeCurrentTime = changeCurrentTime;

  void play() {
    if (_play == null) return;
    _play();
    _isPlaying = true;

    notifyListeners();
  }

  void changeCurrentTime(num v) {
    currentTime = v;
    _changeCurrentTime?.call(v);
  }

  void pause() {
    if (_pause == null) return;
    _pause();
    _isPlaying = false;
    notifyListeners();
  }

  void toggle() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    notifyListeners();
  }

  void start() {
    _isPlaying = true;
    notifyListeners();
  }

  void reset() {
    _isPlaying = false;
    notifyListeners();
  }

  void seekTo(Duration duration) {
    // notifyListeners();
  }

  void setVolume(double volume) {
    // notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    // notifyListeners();
  }

  void setLooping(bool looping) {
    // notifyListeners();
  }

  void setMute(bool mute) {
    // notifyListeners();
  }

  void setPlaybackRate(double rate) {
    // notifyListeners();
  }

  void setPlaybackQuality(String quality) {
    // notifyListeners();
  }

  void setPlaybackRateChange(bool rateChange) {
    // notifyListeners();
  }

  void setPlaybackQualityChange(bool qualityChange) {
    // notifyListeners();
  }

  void setPlaybackRateChangeTime(double rateChangeTime) {
    // notifyListeners();
  }

  void setPlaybackQualityChangeTime(double qualityChangeTime) {
    // notifyListeners();
  }

  void setPlaybackQualityChangeTimeStart(double qualityChangeTimeStart) {
    // notifyListeners();
  }

  void setPlaybackQualityChangeTimeEnd(double qualityChangeTimeEnd) {
    // notifyListeners();
  }

  void setPlaybackRateChangeTimeStart(double rateChangeTimeStart) {
    // notifyListeners();
  }

  void setPlaybackRateChangeTimeEnd(double rateChangeTimeEnd) {
    // notifyListeners();
  }
}

abstract class VideoController {
  void play();
  void pause();

  void currentTime(num v);

  void _initial(VideoState v);

  factory VideoController() => VideoControllerImpl();
}

class VideoControllerImpl implements VideoController {
  VideoState? _videoState;
  @override
  void pause() {
    _videoState?.play();
  }

  @override
  void play() {
    _videoState?.pause();
  }

  @override
  void _initial(v) {
    _videoState = v;
  }

  @override
  void currentTime(num v) {
    _videoState?.changeCurrentTime(v);
  }
}

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    required this.url,
    this.minetype = 'video/mp4',
    this.controls = true,
    this.controller,
    this.currentTime = 0,
    super.key,
  });

  final VideoController? controller;

  // mimetype like video/mp4, video/webm
  final String minetype;

  // video data
  final String url;

  final num currentTime;

  final bool controls;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoControllerImpl _controller;
  late VideoState _videoState;

  html.VideoElement? videoElement;

  void play() {
    videoElement?.play();
  }

  void changeCurrentTime(num v) {
    videoElement?.currentTime = v;
  }

  void pause() {
    videoElement?.pause();
  }

  var _completer = Completer<html.VideoElement>();

  final _currentTime = ValueNotifier(0.0);
  final _isPlaying = ValueNotifier(false);
  void _listen() {
    if (_videoState.currentTime != _currentTime.value) {
      _currentTime.value = _videoState.currentTime.toDouble();
    }
    if (_videoState.isPlaying != _isPlaying.value) {
      _isPlaying.value = _videoState.isPlaying;
    }
  }

  @override
  void initState() {
    _completer = Completer<html.VideoElement>();
    _completer.future.then((v) {
      if (mounted) {
        _videoState = VideoState(
          play: play,
          pause: pause,
          changeCurrentTime: changeCurrentTime,
          currentTime: widget.currentTime,
        );
        _controller =
            (widget.controller ?? VideoController()) as VideoControllerImpl;
        _controller._initial(_videoState);
        _videoState.addListener(_listen);
        setState(() {
          videoElement = v;
        });
        _videoState.currentTime = videoElement!.currentTime;
        videoElement!.addEventListener('timeupdate', (_) {
          _videoState.currentTime = videoElement!.currentTime;
        });
      }
    });
    ui_web.platformViewRegistry.registerViewFactory('video-flutter',
        (int viewId) {
      final sourceElement = html.SourceElement();
      sourceElement.type = widget.minetype;
      sourceElement.src = widget.url;

      final videoElement = html.VideoElement();
      // videoElement.controls = widget.controls;
      videoElement.load();
      videoElement.children = [sourceElement];
      videoElement.style.height = '100%';
      videoElement.style.objectFit = 'fill';
      videoElement.style.width = '100%';
      videoElement.id = 'video-flutter-$viewId';

      videoElement.addEventListener('loadeddata', (_) {
        if (_completer.isCompleted) {
          return;
        }
        log('==============registered');
        videoElement.currentTime = widget.currentTime;
        _completer.complete(videoElement);
      });

      return videoElement;
    });

    super.initState();
  }

  @override
  void dispose() {
    _videoState.removeListener(_listen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HtmlElementView(
          viewType: 'video-flutter',
        ),
        if (videoElement != null)
          Positioned.fill(
            child: Center(
              child: ValueListenableBuilder(
                  valueListenable: _isPlaying,
                  builder: (_, v, __) {
                    return IconButton(
                      icon: Icon(
                        v ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (v) {
                          _controller.play();
                        } else {
                          _controller.pause();
                        }
                      },
                      iconSize: 2.rem.toDouble(),
                    );
                  }),
            ),
          ),
        if (videoElement != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: _currentTime,
              builder: (_, v, __) {
                return Slider(
                  value: v / videoElement!.duration,
                  onChanged: (value) {
                    _controller.currentTime(value * videoElement!.duration);
                  },
                );
              },
            ),
          )
        else
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
