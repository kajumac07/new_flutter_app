import 'package:flutter/material.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';

class ReusableText extends StatelessWidget {
  const ReusableText({
    super.key,
    required this.text,
    required this.size,
    required this.color,
    required this.fw,
  });

  final String text;
  final double size;
  final Color color;
  final FontWeight fw;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      softWrap: false,
      textAlign: TextAlign.left,
      style: appStyle(size, color, fw),
    );
  }
}
