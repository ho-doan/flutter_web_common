import 'package:flutter/material.dart';

class PointerWidget extends StatefulWidget {
  const PointerWidget({super.key, required this.child});

  final Widget child;

  @override
  State<PointerWidget> createState() => _PointerWidgetState();
}

class _PointerWidgetState extends State<PointerWidget> {
  final _position = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (e) {
        _position.value = Offset(
          e.localPosition.dx - 7.5,
          e.localPosition.dy - 7.5,
        );
      },
      child: Stack(
        children: [
          widget.child,
          ValueListenableBuilder(
              valueListenable: _position,
              builder: (_, position, __) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  top: position.dy,
                  left: position.dx,
                  child: ValueListenableBuilder(
                    valueListenable: _position,
                    builder: (_, v, __) {
                      return IgnorePointer(
                        child: ClipPath(
                          clipper: DiamondClipper(),
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
