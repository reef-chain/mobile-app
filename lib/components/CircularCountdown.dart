import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    this.fillColor,
    required this.ringColor,
    this.strokeWidth = 1.5,
    required this.strokeCap,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color? fillColor;
  final Color ringColor;
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
      paint.color = fillColor!;
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
  const CircularCountDown({
    required this.countdownMs,
    this.width = 15.0,
    this.height = 15.0,
    this.strokeWidth = 1.5,
    this.fillColor,
    this.svgAssetPath,
  });

  final int countdownMs;
  final double width;
  final double height;
  final double strokeWidth;
  final Color? fillColor;
  final String? svgAssetPath;

  @override
  CircularCountDownState createState() => CircularCountDownState();
}

class CircularCountDownState extends State<CircularCountDown>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countDownAnimation;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.countdownMs),
    );

    _countDownAnimation = Tween<double>(begin: 1, end: 0).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.countdownMs), () {
      setState(() {
        _isCompleted = true;
      });
    });

    _controller.reverse(from: 1);
  }

  @override
  Widget build(BuildContext context) {
    return _isCompleted
        ? Gap(2)
        : SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Align(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: CustomPaint(
                          painter: CustomTimerPainter(
                            animation: _countDownAnimation,
                            fillColor: widget.fillColor ?? Styles.primaryAccentColor,
                            ringColor: Styles.whiteColor,
                            strokeWidth: widget.strokeWidth,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (widget.svgAssetPath != null)
                  SizedBox(
                    width: widget.width * 0.5,
                    height: widget.height * 0.5,
                    child: SvgPicture.asset(
                      widget.svgAssetPath!,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
