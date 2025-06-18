import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';

class GlowingIconButton extends StatefulWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback onTap;

  const GlowingIconButton({
    required this.icon,
    this.badge = false,
    required this.onTap,
  });

  @override
  _GlowingIconButtonState createState() => _GlowingIconButtonState();
}

class _GlowingIconButtonState extends State<GlowingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow Effect
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: kPrimary.withOpacity(_glowController.value * 0.3),
                color: kSecondary,
              ),
            );
          },
        ),

        // Icon Button
        IconButton(
          icon: Icon(widget.icon, color: Colors.white, size: 24.sp),
          onPressed: widget.onTap,
        ),

        // Badge
        if (widget.badge)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
