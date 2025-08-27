// app/global/widgets/story_circle.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';

class StoryCircle extends StatelessWidget {
  final bool hasStory;
  final String imageUrl;
  final VoidCallback onTap;
  final double size;

  const StoryCircle({
    Key? key,
    required this.hasStory,
    required this.imageUrl,
    required this.onTap,
    this.size = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(hasStory ? 2.5 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasStory
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kPrimary, kSecondary],
                )
              : null,
        ),
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: kCardColor),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: kSecondary.withOpacity(0.2),
                child: Center(
                  child: CircularProgressIndicator(
                    color: kPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: kSecondary.withOpacity(0.2),
                child: Icon(Icons.person, color: kWhite),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
