import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingOverlay extends StatefulWidget {
  final String? title;
  final String? content;

  const LoadingOverlay({super.key, this.title, this.content});

  @override
  LoadingOverlayState createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> scale1, scale2, scale3;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();

    scale1 = TestTween(begin: 0.9, end: 1.1, delay: 0.0)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
    scale2 = TestTween(begin: 0.9, end: 1.1, delay: 0.33)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
    scale3 = TestTween(begin: 0.9, end: 1.1, delay: 0.66)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
      child: Scaffold(
        backgroundColor: Colors.white.withOpacity(0.6),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedBuilder(
                      animation: _controller!,
                      builder: (context, snapshot) {
                        return Transform.scale(
                          scale: scale1.value,
                          child: SvgPicture.asset(
                            'assets/icons/simbolo.svg',
                            color: Color.fromRGBO(255, 199, 38, 1.0),
                          ),
                        );
                      }),
                  AnimatedBuilder(
                      animation: _controller!,
                      builder: (context, snapshot) {
                        return Transform.scale(
                          scale: scale2.value,
                          child: SvgPicture.asset(
                            'assets/icons/simbolo.svg',
                            color: Color.fromRGBO(0, 53, 173, 1.0),
                          ),
                        );
                      }),
                  AnimatedBuilder(
                      animation: _controller!,
                      builder: (context, snapshot) {
                        return Transform.scale(
                          scale: scale3.value,
                          child: SvgPicture.asset(
                            'assets/icons/simbolo.svg',
                            color: Color.fromRGBO(243, 4, 55, 1.0),
                          ),
                        );
                      }),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                widget.title ?? '',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.content ?? '',
                style: const TextStyle(fontSize: 16.0, fontFamily: 'Light'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestTween extends Tween<double> {
  final double delay;

  TestTween({double? begin, double? end, required this.delay})
      : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    return super.lerp((sin((t - delay) * 2 * pi) + 1) / 2);
  }
}
