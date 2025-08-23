import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';

class EnhancedGallerySection extends StatefulWidget {
  final List<String> images;

  const EnhancedGallerySection({super.key, required this.images});

  @override
  State<EnhancedGallerySection> createState() => _EnhancedGallerySectionState();
}

class _EnhancedGallerySectionState extends State<EnhancedGallerySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _hoverIndex = -1;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Travel Gallery',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${widget.images.length} photos',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: kSecondary.withAlpha(100),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Explore the visual journey of this travel story',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24.h),

          // Interactive Gallery with different layouts
          _buildInteractiveGallery(),

          // SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildInteractiveGallery() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(),
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.h,
            childAspectRatio: _getAspectRatio(),
          ),
          itemCount: widget.images.length > 9 ? 9 : widget.images.length,
          itemBuilder: (context, index) {
            return _buildGalleryItem(index);
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount() {
    if (widget.images.length == 1) return 1;
    if (widget.images.length == 2) return 2;
    if (widget.images.length <= 4) return 2;
    return 3;
  }

  double _getAspectRatio() {
    if (widget.images.length == 1) return 1.5;
    if (widget.images.length == 2) return 1.2;
    if (widget.images.length <= 4) return 1.0;
    return 1.0;
  }

  Widget _buildGalleryItem(int index) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoverIndex = index),
      onExit: (_) => setState(() => _hoverIndex = -1),
      child: GestureDetector(
        onTap: () {
          _openFullScreenGallery(context, index);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with shimmer effect
            _buildImageWithShimmer(index),

            // Overlay for more than 9 images
            if (index == 8 && widget.images.length > 9)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Text(
                    '+${widget.images.length - 9}',
                    style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Hover overlay with zoom icon
            if (_hoverIndex == index)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.zoom_in_outlined,
                    size: 32.sp,
                    color: Colors.white,
                  ),
                ),
              ),

            // Index badge for larger galleries
            if (widget.images.length > 3)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithShimmer(int index) {
    return Hero(
      tag: 'gallery_image_$index',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: kCardColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.network(
            widget.images[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kCardColor,
                      kCardColor.withOpacity(0.5),
                      kCardColor,
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: kSecondary,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 32.sp,
                  color: Colors.grey.shade400,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images.length > 5 ? 5 : widget.images.length,
        (index) => Container(
          width: 8.w,
          height: 8.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0 ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  void _openFullScreenGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullScreenGallery(
              images: widget.images,
              initialIndex: initialIndex,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}

// Enhanced Full-screen gallery view
class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  double _currentScale = 1.0;
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for images
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _currentScale = 1.0;
                _transformationController.value = Matrix4.identity();
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: _currentScale == 1.0,
                minScale: 0.5,
                maxScale: 3.0,
                onInteractionUpdate: (ScaleUpdateDetails details) {
                  setState(() {
                    _currentScale = details.scale;
                  });
                },
                child: Hero(
                  tag: 'gallery_image_$index',
                  child: Center(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // App bar with back button and image count
          Positioned(
            top: 60.h,
            left: 24.w,
            right: 24.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom thumbnail gallery
          if (widget.images.length > 1)
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Container(
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.images.length,
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: _currentIndex == index
                                ? Colors.blue.shade400
                                : Colors.transparent,
                            width: 2.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Zoom controls
          if (_currentScale != 1.0)
            Positioned(
              right: 24.w,
              bottom: 120.h,
              child: Column(
                children: [
                  _buildControlButton(
                    icon: Icons.zoom_out,
                    onTap: () {
                      setState(() {
                        _currentScale = 1.0;
                        _transformationController.value = Matrix4.identity();
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildControlButton(
                    icon: Icons.fullscreen_exit,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }
}
