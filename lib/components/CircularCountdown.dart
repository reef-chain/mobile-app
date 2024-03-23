import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:reef_mobile_app/utils/styles.dart';

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.fillColor,
    required this.ringColor,
    required this.strokeWidth,
    required this.strokeCap,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color fillColor, ringColor;
  final double strokeWidth;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ringColor
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);
    double progress = (animation.value) * 2 * math.pi;
    double startAngle = math.pi * 1.5;

    if (fillColor != null) {
      paint.color = fillColor;
    }

    canvas.drawArc(Offset.zero & size, startAngle, progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        ringColor != oldDelegate.ringColor ||
        fillColor != oldDelegate.fillColor;
  }
}

class CircularCountDown extends StatefulWidget {
  const CircularCountDown({required this.countdownMs});
  final int countdownMs;

  @override
  CircularCountDownState createState() => CircularCountDownState();
}
class CircularCountDownState extends State<CircularCountDown>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countDownAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.countdownMs),
    );

    _countDownAnimation =
        Tween<double>(begin: 1, end: 0).animate(_controller);

    _controller.reverse(from: 1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      height: 15,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Align(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CustomPaint(
                  painter: CustomTimerPainter(
                    animation: _countDownAnimation,
                    fillColor: Styles.whiteColor,
                    ringColor: Colors.transparent,
                    strokeWidth: 1.5,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
