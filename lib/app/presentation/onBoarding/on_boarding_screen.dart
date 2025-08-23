import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/global/widgets/custom_container.dart';
import 'package:new_flutter_app/app/presentation/auth/register/register_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Explore New Horizons",
      description: "Embark on unforgettable journeys and find hidden gems.",
      lottieAsset: "https://assets6.lottiefiles.com/packages/lf20_3vbOcw.json",
      color: kWhite,
    ),
    OnboardingItem(
      title: "Connect with Bloggers",
      description: "Follow expert bloggers & locals for real-time tips.",
      lottieAsset:
          "https://assets6.lottiefiles.com/packages/lf20_zw0djhar.json",
      color: kWhite,
    ),
    OnboardingItem(
      title: "Create & Share Adventures",
      description: "Build your travel diary and inspire the world.",
      lottieAsset:
          "https://assets6.lottiefiles.com/packages/lf20_0skurerf.json",
      color: kWhite,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: kCardColor,
      body: CustomGradientContainer(
        child: Stack(
          children: [
            // Curved Top Left
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   child: ClipPath(
            //     clipper: TopLeftCurveClipper(),
            //     child: Container(
            //       width: 200.w,
            //       height: 200.h,
            //       color: kPrimary.withOpacity(0.2),
            //     ),
            //   ),
            // ),

            // // Curved Bottom Right
            // Positioned(
            //   bottom: 0,
            //   right: 0,
            //   child: ClipPath(
            //     clipper: BottomRightCurveClipper(),
            //     child: Container(
            //       width: 250.w,
            //       height: 250.h,
            //       color: kSecondary.withOpacity(0.2),
            //     ),
            //   ),
            // ),

            // PageView
            PageView.builder(
              controller: _pageController,
              itemCount: _onboardingItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildOnboardingPage(_onboardingItems[index]);
              },
            ),

            // Bottom Section
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingItems.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: kSecondary,
                      dotColor: kDark,
                      dotHeight: 8.h,
                      dotWidth: 8.w,
                      spacing: 8.w,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _onboardingItems.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Get.offAll(() => RegisterScreen());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 15.h,
                          horizontal: 40.w,
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        _currentPage == _onboardingItems.length - 1
                            ? "Get Started"
                            : "Next",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: kWhite,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (_currentPage != _onboardingItems.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.jumpToPage(_onboardingItems.length - 1);
                      },
                      child: Text(
                        "Skip",
                        style: appStyle(14, kDark, FontWeight.w200),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 320.h,
            child: Lottie.network(
              item.lottieAsset,
              fit: BoxFit.contain,
              animate: true,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            item.title,
            style: appStyleRaleway(26, kDark, FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          Text(
            item.description,
            style: appStylePoppins(15, kDark, FontWeight.w400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
  });
}

// Custom clippers for top-left and bottom-right curves
class TopLeftCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.2,
      size.width * 0.6,
      0,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomRightCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.8,
      size.width * 0.4,
      size.height,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
