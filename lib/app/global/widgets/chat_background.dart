import 'package:flutter/material.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';

class ChatBackground extends StatelessWidget {
  final Widget child;
  const ChatBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kCardColor,
      child: CustomPaint(painter: DottedBackgroundPainter(), child: child),
    );
  }
}

class DottedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const double spacing = 40;
    const double radius = 2;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
