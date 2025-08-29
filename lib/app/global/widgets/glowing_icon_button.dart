import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';

class GlowingIconButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;
  final Color? iconColor;
  final double? iconSize;

  const GlowingIconButton({
    Key? key,
    required this.icon,
    required this.badgeCount,
    required this.onTap,
    this.iconColor,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: kSecondary,
            child: Icon(
              icon,
              color: iconColor ?? kWhite,
              size: iconSize ?? 24.sp,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(1),
                constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: kWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : badgeCount.toString(),
                  style: TextStyle(
                    color: kSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
