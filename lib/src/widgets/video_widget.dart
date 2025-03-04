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
  VideoState? _videoState;
  void play();
  void pause();

  void currentTime(num v);

  void _initial(VideoState v);

  factory VideoController() => VideoControllerImpl(null);
}

class VideoControllerImpl extends ValueNotifier implements VideoController {
  @override
  void pause() {
    _videoState?.pause();
  }

  @override
  void play() {
    _videoState?.play();
  }

  @override
  void _initial(v) {
    _videoState = v;
  }

  @override
  void currentTime(num v) {
    _videoState?.changeCurrentTime(v);
    notifyListeners();
  }

  @override
  VideoState? _videoState;

  VideoControllerImpl(super.value);
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
  VideoState? _videoState;

  final videoElement = ValueNotifier<html.VideoElement?>(null);

  void play() {
    videoElement.value?.play();
  }

  void changeCurrentTime(num v) {
    videoElement.value?.currentTime = v;
  }

  void pause() {
    videoElement.value?.pause();
  }

  final _currentTime = ValueNotifier(0.0);
  final _isPlaying = ValueNotifier(false);
  void _listen() {
    if (_videoState != null && _videoState!.currentTime != _currentTime.value) {
      _currentTime.value = _videoState!.currentTime.toDouble();
    }
    if (_videoState != null && _videoState!.isPlaying != _isPlaying.value) {
      _isPlaying.value = _videoState!.isPlaying;
    }
  }

  @override
  void initState() {
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

      return videoElement;
    });
    super.initState();
  }

  void _tListen(_) {
    _videoState?.currentTime = videoElement.value!.currentTime;
  }

  bool isInitial = true;

  void _vListen(_, html.VideoElement mVideoElement) {
    log('--------- ${mVideoElement.id} ${widget.controller}');
    _videoState = widget.controller?._videoState ??
        VideoState(
          play: play,
          pause: pause,
          changeCurrentTime: changeCurrentTime,
          currentTime: widget.currentTime,
        );
    _controller =
        (widget.controller ?? VideoController()) as VideoControllerImpl;
    _controller._initial(_videoState!);
    _videoState!.addListener(_listen);
    videoElement.value = mVideoElement;
    if (isInitial) {
      isInitial = false;
      mVideoElement.currentTime = _videoState!.currentTime;
      print(
          '-------- initial ${mVideoElement.id} ${_videoState!.currentTime} ${mVideoElement.currentTime}');
    }
  }

  @override
  void dispose() {
    widget.controller?.pause();
    _videoState?.removeListener(_listen);
    if (videoElement.value != null) {
      videoElement.value?.removeEventListener(
        'loadedmetadata',
        (_) => _vListen(_, videoElement.value!),
      );
      videoElement.value?.removeEventListener('timeupdate', (_) => _tListen(_));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: ValueKey('stack-1-${widget.key?.toString()}'),
      children: [
        HtmlElementView(
          key: UniqueKey(),
          viewType: 'video-flutter',
          onPlatformViewCreated: (id) {
            final mVideoElement = ui_web.platformViewRegistry.getViewById(id)
                as html.VideoElement;
            mVideoElement.addEventListener(
              'loadedmetadata',
              (_) => _vListen(_, mVideoElement),
            );
            mVideoElement.addEventListener('timeupdate', _tListen);
          },
        ),
        Positioned.fill(
          key: ValueKey('fill-1-${widget.key?.toString()}'),
          child: ValueListenableBuilder(
              key: ValueKey('listen-1-${widget.key?.toString()}'),
              valueListenable: videoElement,
              builder: (_, element, __) {
                return Stack(
                  key: ValueKey('stack-2-${widget.key?.toString()}'),
                  children: [
                    if (element != null)
                      SizedBox.expand(
                        child: Center(
                          child: ValueListenableBuilder(
                            key: ValueKey('video-flutter-action-${element.id}'),
                            valueListenable: _isPlaying,
                            builder: (_, v, __) {
                              return IconButton(
                                icon: Icon(
                                  v ? Icons.pause : Icons.play_arrow,
                                ),
                                onPressed: () {
                                  if (v) {
                                    _controller.pause();
                                  } else {
                                    _controller.play();
                                  }
                                },
                                iconSize: 2.rem.toDouble(),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      const SizedBox.expand(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (element != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ValueListenableBuilder(
                          key: ValueKey('video-flutter-v-slider-${element.id}'),
                          valueListenable: _currentTime,
                          builder: (_, v, __) {
                            return Slider(
                              key: ValueKey(
                                  'video-flutter-slider-${element.id}'),
                              value: v / element.duration,
                              onChanged: (value) {
                                _controller
                                    .currentTime(value * element.duration);
                              },
                            );
                          },
                        ),
                      )
                  ],
                );
              }),
        ),
      ],
    );
  }
}
