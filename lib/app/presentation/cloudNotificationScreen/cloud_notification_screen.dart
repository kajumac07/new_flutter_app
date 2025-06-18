import 'package:flutter/material.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';

class CloudNotificationScreen extends StatelessWidget {
  const CloudNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          'Cloud Notification',
          style: appStyle(24, kDark, FontWeight.normal),
        ),
      ),
    );
  }
}
