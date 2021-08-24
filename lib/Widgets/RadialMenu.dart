// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:vector_math/vector_math.dart' show radians;

// Project imports:
import 'package:nyzo_wallet/Data/AppLocalizations.dart';
import 'TransactionsWidget.dart';

class RadialMenu extends StatefulWidget {
  final double? width;
  final double? height;
  const RadialMenu({this.width, this.height});
  @override
  _RadialMenuState createState() =>
      _RadialMenuState(width: width, height: height);
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  final double? width;
  final double? height;
  _RadialMenuState({this.width, this.height});
  int activeWindow = 3;
  Tween<double>? _tween;
  Animation<double>? _animation;
  AnimationController? _controller;
  double radi = 500;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _tween = Tween(begin: 0.0, end: 360.0);
    _animation = _tween!.animate(
        CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn));
  }

  Widget menuButton(Icon icon, String tag, VoidCallback onPressed) {
    return Container(
      width: width! / 7,
      height: width! / 7,
      child: FloatingActionButton(
        child: icon,
        onPressed: onPressed,
        heroTag: tag,
      ),
    );
  }

  _animate(double end) {
    _tween!.begin = _tween!.end;
    _controller!.reset();
    _tween!.end = end;

    _controller!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xff136207),
      child: Column(
        children: <Widget>[
          AnimatedBuilder(
            animation: _animation!,
            builder: (context, builder) {
              return Stack(
                fit: StackFit.loose,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                      child: Transform.rotate(
                          angle: radians(_animation!.value),
                          child: Container(
                              color: const Color(0xffa4a4a4),
                              width: 100,
                              height: 100,
                              child: Stack(
                                clipBehavior: Clip.none,
                                fit: StackFit.passthrough,
                                key: const Key('Spinnable'),
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Positioned(
                                    right: 0.0,
                                    left: radi * cos(radians(0)),
                                    top: 0.0,
                                    bottom: 0.0,
                                    child: Transform.rotate(
                                        angle: radians(0.0 + 90),
                                        child: Container(
                                          width: 10.0,
                                          height: 10.0,
                                          child:
                                              const Icon(Icons.accessibility),
                                        )),
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    left: radi * cos(radians(360 / 5)),
                                    top: 0.0,
                                    bottom: radi * sin(radians(360 / 5)),
                                    child: Transform.rotate(
                                      angle: radians(-360 / 5 + 90),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        child: const TranSactionsWidget([]),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    left: radi * cos(radians(360 / 5 * 2)),
                                    top: 0.0,
                                    bottom: radi * sin(radians(360 / 5 * 2)),
                                    child: Transform.rotate(
                                      angle: radians(-360 / 5 * 2 + 90),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        child: const Icon(Icons.accessibility),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    left: radi * cos(radians(360 / 5 * 3)),
                                    top: 0.0,
                                    bottom: radi * sin(radians(360 / 5 * 3)),
                                    child: Transform.rotate(
                                      angle: radians(-360 / 5 * 3 + 90),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        child: const Icon(Icons.accessibility),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0.0,
                                    left:
                                        radi / 1.0 * cos(radians(360 / 5 * 4)),
                                    top: 0.0,
                                    bottom: radi * sin(radians(360 / 5 * 4)),
                                    child: Transform.rotate(
                                      angle: radians(-360 / 5 * 4 + 90),
                                      child: Container(
                                        width: 100.0,
                                        height: 100.0,
                                        child: const Icon(Icons.accessibility),
                                      ),
                                    ),
                                  ),
                                ],
                              )))),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              menuButton(const Icon(Icons.settings),
                  AppLocalizations.of(context)!.translate('String30'), () {
                activeWindow = 4;
                _animate(360 * 4 / 5 - 90);
              }),
              menuButton(const Icon(Icons.contacts),
                  AppLocalizations.of(context)!.translate('String8'), () {
                activeWindow = 3;
                _animate(360 * 3 / 5 - 90);
              }),
              menuButton(const Icon(Icons.history),
                  AppLocalizations.of(context)!.translate('String72'), () {
                activeWindow = 0;
                _animate(0.0 - 90);
              }),
              menuButton(const Icon(Icons.send),
                  AppLocalizations.of(context)!.translate('String22'), () {
                activeWindow = 1;
                _animate(360 * 1 / 5 - 90);
              }),
              menuButton(const Icon(Icons.call_received),
                  AppLocalizations.of(context)!.translate('String23'), () {
                activeWindow = 2;
                _animate(360 * 2 / 5 - 90);
              })
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
          )
        ],
      ),
    );
  }
}

class CustomRect extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    return rect;
  }

  @override
  bool shouldReclip(CustomRect oldClipper) {
    return true;
  }
}
