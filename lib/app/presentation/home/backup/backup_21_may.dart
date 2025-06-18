// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:jj_app/app/presentation/cloudNotificationScreen/cloud_notification_screen.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:get/get.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF0F0F1A),
//       body: CustomScrollView(
//         physics: BouncingScrollPhysics(),
//         slivers: [
//           // 1. Cosmic App Bar
//           SliverAppBar(
//             expandedHeight: 150.h,
//             floating: true,
//             pinned: true,
//             snap: true,
//             stretch: true,
//             backgroundColor: Colors.transparent,
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.pin,
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0xFF3A1C71).withOpacity(0.8),
//                       Colors.transparent,
//                     ],
//                   ),
//                 ),
//               ),
//               title: Text(
//                 'VOYAGER',
//                 style: TextStyle(
//                   fontSize: 28.sp,
//                   fontWeight: FontWeight.w900,
//                   color: Colors.white,
//                   letterSpacing: 2.5,
//                   shadows: [
//                     Shadow(
//                       color: Colors.purple.withOpacity(0.5),
//                       blurRadius: 10,
//                       offset: Offset(0, 0),
//                     ),
//                   ],
//                 ),
//               ),
//               centerTitle: true,
//             ),
//             leading: IconButton(
//               icon: Icon(Icons.menu_rounded, color: Colors.white, size: 28.sp),
//               onPressed: () {},
//             ),
//             actions: [
//               _GlowingIconButton(icon: Icons.search, onTap: () {}),
//               SizedBox(width: 12.w),
//               _GlowingIconButton(
//                 icon: Icons.notifications,
//                 badge: true,
//                 onTap: () => Get.to(() => CloudNotificationScreen()),
//               ),
//               SizedBox(width: 12.w),
//             ],
//           ),

//           // 2. Interstellar Hero Carousel
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 320.h,
//               child: PageView.builder(
//                 itemCount: 3,
//                 controller: PageController(viewportFraction: 0.85),
//                 padEnds: false,
//                 itemBuilder: (_, index) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 20.h,
//                     ),
//                     child: _GalacticDestinationCard(
//                       imageUrl:
//                           [
//                             'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
//                             'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
//                             'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
//                           ][index],
//                       title:
//                           [
//                             'Cosmic Himalayas',
//                             'Nebula Beaches',
//                             'Stellar Deserts',
//                           ][index],
//                       subtitle:
//                           [
//                             '5D Experience',
//                             'Infinite Relaxation',
//                             'Martian Vibes',
//                           ][index],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           // 3. Warp-Speed Categories
//           SliverPadding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//             sliver: SliverGrid(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 childAspectRatio: 0.9,
//                 mainAxisSpacing: 12.h,
//                 crossAxisSpacing: 12.w,
//               ),
//               delegate: SliverChildBuilderDelegate((_, index) {
//                 return _HolographicCategory(
//                   emoji:
//                       ['🚀', '🌌', '🪐', '🌠', '👽', '🛸', '🔭', '🌍'][index],
//                   label:
//                       [
//                         'Space',
//                         'Galaxy',
//                         'Planets',
//                         'Stars',
//                         'Aliens',
//                         'UFO',
//                         'Telescope',
//                         'Earth',
//                       ][index],
//                 );
//               }, childCount: 8),
//             ),
//           ),

//           // 4. Nebula Stories
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 10.h),
//               child: Text(
//                 'NEBULA STORIES',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 260.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.only(left: 20.w, right: 20.w),
//                 itemCount: 4,
//                 itemBuilder: (_, index) {
//                   return _QuantumStoryCard(
//                     imageUrl:
//                         [
//                           'https://images.unsplash.com/photo-1582972236019-ea9dfa7b0c9c',
//                           'https://images.unsplash.com/photo-1527631746610-bca00a040d60',
//                           'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
//                           'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
//                         ][index],
//                     title:
//                         [
//                           'Wormhole Trek',
//                           'Black Hole Dive',
//                           'Supernova Camp',
//                           'Andromeda Tour',
//                         ][index],
//                     author:
//                         [
//                           'Dr. Space',
//                           'Cosmo Girl',
//                           'Star Lord',
//                           'Galaxy Queen',
//                         ][index],
//                   );
//                 },
//               ),
//             ),
//           ),

//           // 5. Celestial Destinations
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(left: 20.w, top: 30.h, bottom: 10.h),
//               child: Text(
//                 'CELESTIAL DESTINATIONS',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ),
//           ),
//           SliverPadding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w),
//             sliver: SliverGrid(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.3,
//                 mainAxisSpacing: 16.h,
//                 crossAxisSpacing: 16.w,
//               ),
//               delegate: SliverChildBuilderDelegate((_, index) {
//                 return _StellarDestination(
//                   imageUrl:
//                       [
//                         'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
//                         'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
//                         'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
//                         'https://images.unsplash.com/photo-1582972236019-ea9dfa7b0c9c',
//                       ][index],
//                   title:
//                       [
//                         'Moon Resort',
//                         'Mars Colony',
//                         'Jupiter Spa',
//                         'Venus Retreat',
//                       ][index],
//                 );
//               }, childCount: 4),
//             ),
//           ),

//           // 6. Astral Testimonials
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(left: 20.w, top: 40.h, bottom: 10.h),
//               child: Text(
//                 'ASTRAL TESTIMONIALS',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 220.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.only(left: 20.w, right: 20.w),
//                 itemCount: 3,
//                 itemBuilder: (_, index) {
//                   return _CosmicTestimonial(
//                     avatarUrl:
//                         'https://randomuser.me/api/portraits/women/${index + 30}.jpg',
//                     name: ['Nebula N.', 'Stella S.', 'Luna L.'][index],
//                     quote:
//                         [
//                           'This app teleported me to another dimension of travel!',
//                           'Never imagined experiencing zero-gravity tourism so easily!',
//                           'Worth every light-year traveled for these experiences!',
//                         ][index],
//                   );
//                 },
//               ),
//             ),
//           ),

//           // 7. Black Hole Footer
//           SliverToBoxAdapter(
//             child: Container(
//               margin: EdgeInsets.only(top: 40.h),
//               padding: EdgeInsets.symmetric(vertical: 40.h),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color(0xFF3A1C71).withOpacity(0.5),
//                     Color(0xFF0F0F1A),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     'BEGIN YOUR COSMIC JOURNEY',
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                   SizedBox(height: 20.h),
//                   Container(
//                     width: 200.w,
//                     height: 50.h,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(25.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color(0xFF9D50BB).withOpacity(0.5),
//                           blurRadius: 20,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(25.r),
//                         onTap: () {},
//                         child: Center(
//                           child: Text(
//                             'LAUNCH APP',
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 30.h),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _SocialIcon(
//                         icon: Icons.rocket_launch,
//                         color: Colors.purpleAccent,
//                       ),
//                       SizedBox(width: 20.w),
//                       _SocialIcon(
//                         icon: Icons.satellite_alt,
//                         color: Colors.blueAccent,
//                       ),
//                       SizedBox(width: 20.w),
//                       _SocialIcon(icon: Icons.star, color: Colors.yellowAccent),
//                     ],
//                   ),
//                   SizedBox(height: 30.h),
//                   Text(
//                     '© 3025 VOYAGER. All rights reserved.',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.white.withOpacity(0.5),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Custom Widgets with Shimmer Effects
// class _GalacticDestinationCard extends StatelessWidget {
//   final String imageUrl;
//   final String title;
//   final String subtitle;

//   const _GalacticDestinationCard({
//     required this.imageUrl,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(28.r),
//       child: Stack(
//         children: [
//           // Cached Image with Shimmer
//           CachedNetworkImage(
//             imageUrl: imageUrl,
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//             placeholder:
//                 (context, url) => Shimmer.fromColors(
//                   baseColor: Colors.grey.shade800,
//                   highlightColor: Colors.grey.shade700,
//                   child: Container(
//                     color: Colors.grey.shade900,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//                 ),
//             errorWidget: (context, url, error) => Icon(Icons.error),
//           ),

//           // Gradient Overlay
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
//               ),
//             ),
//           ),

//           // Pulsing Glow Effect
//           Positioned.fill(
//             child: IgnorePointer(
//               child: AnimatedContainer(
//                 duration: Duration(seconds: 3),
//                 curve: Curves.easeInOut,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(28.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.purpleAccent.withOpacity(0.2),
//                       blurRadius: 30,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Content
//           Padding(
//             padding: EdgeInsets.all(24.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 24.sp,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.white,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black,
//                         blurRadius: 10,
//                         offset: Offset(2, 2),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Row(
//                   children: [
//                     Icon(Icons.star, color: Colors.yellowAccent, size: 18.w),
//                     SizedBox(width: 8.w),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: Colors.white.withOpacity(0.9),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HolographicCategory extends StatelessWidget {
//   final String emoji;
//   final String label;

//   const _HolographicCategory({required this.emoji, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18.r),
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFF3A1C71).withOpacity(0.3),
//             Color(0xFF6E48AA).withOpacity(0.3),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         border: Border.all(
//           color: Colors.purpleAccent.withOpacity(0.3),
//           width: 1.5,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(18.r),
//           onTap: () {},
//           splashColor: Colors.purpleAccent.withOpacity(0.2),
//           highlightColor: Colors.transparent,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(emoji, style: TextStyle(fontSize: 32.sp)),
//               SizedBox(height: 8.h),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _QuantumStoryCard extends StatelessWidget {
//   final String imageUrl;
//   final String title;
//   final String author;

//   const _QuantumStoryCard({
//     required this.imageUrl,
//     required this.title,
//     required this.author,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 180.w,
//       margin: EdgeInsets.only(right: 16.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 20,
//             spreadRadius: 2,
//             offset: Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Cached Image with Shimmer
//           ClipRRect(
//             borderRadius: BorderRadius.circular(24.r),
//             child: CachedNetworkImage(
//               imageUrl: imageUrl,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//               placeholder:
//                   (context, url) => Shimmer.fromColors(
//                     baseColor: Colors.grey.shade800,
//                     highlightColor: Colors.grey.shade700,
//                     child: Container(
//                       color: Colors.grey.shade900,
//                       width: double.infinity,
//                       height: double.infinity,
//                     ),
//                   ),
//             ),
//           ),

//           // Content
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   'By $author',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.white.withOpacity(0.8),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Floating Action Button
//           Positioned(
//             top: 12.w,
//             right: 12.w,
//             child: Container(
//               width: 36.w,
//               height: 36.h,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.bookmark_border,
//                 color: Colors.white,
//                 size: 18.w,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StellarDestination extends StatelessWidget {
//   final String imageUrl;
//   final String title;

//   const _StellarDestination({required this.imageUrl, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.r),
//       child: Stack(
//         children: [
//           // Cached Image with Shimmer
//           CachedNetworkImage(
//             imageUrl: imageUrl,
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//             placeholder:
//                 (context, url) => Shimmer.fromColors(
//                   baseColor: Colors.grey.shade800,
//                   highlightColor: Colors.grey.shade700,
//                   child: Container(
//                     color: Colors.grey.shade900,
//                     width: double.infinity,
//                     height: double.infinity,
//                   ),
//                 ),
//           ),

//           // Gradient Overlay
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//               ),
//             ),
//           ),

//           // Content
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Floating Rating
//           Positioned(
//             top: 12.w,
//             left: 12.w,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.star, color: Colors.yellow, size: 14.w),
//                   SizedBox(width: 4.w),
//                   Text(
//                     '4.9',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CosmicTestimonial extends StatelessWidget {
//   final String avatarUrl;
//   final String name;
//   final String quote;

//   const _CosmicTestimonial({
//     required this.avatarUrl,
//     required this.name,
//     required this.quote,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 280.w,
//       margin: EdgeInsets.only(right: 16.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24.r),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF3A1C71).withOpacity(0.3),
//             Color(0xFF6E48AA).withOpacity(0.3),
//           ],
//         ),
//         border: Border.all(
//           color: Colors.purpleAccent.withOpacity(0.2),
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 // Cached Avatar with Shimmer
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12.r),
//                   child: CachedNetworkImage(
//                     imageUrl: avatarUrl,
//                     width: 50.w,
//                     height: 50.h,
//                     fit: BoxFit.cover,
//                     placeholder:
//                         (context, url) => Shimmer.fromColors(
//                           baseColor: Colors.grey.shade800,
//                           highlightColor: Colors.grey.shade700,
//                           child: Container(
//                             color: Colors.grey.shade900,
//                             width: 50.w,
//                             height: 50.h,
//                           ),
//                         ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       'Space Explorer',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.white.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 16.h),
//             Expanded(
//               child: Text(
//                 '"$quote"',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   color: Colors.white.withOpacity(0.9),
//                   fontStyle: FontStyle.italic,
//                   height: 1.6,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _GlowingIconButton extends StatefulWidget {
//   final IconData icon;
//   final bool badge;
//   final VoidCallback onTap;

//   const _GlowingIconButton({
//     required this.icon,
//     this.badge = false,
//     required this.onTap,
//   });

//   @override
//   __GlowingIconButtonState createState() => __GlowingIconButtonState();
// }

// class __GlowingIconButtonState extends State<_GlowingIconButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _glowController;

//   @override
//   void initState() {
//     super.initState();
//     _glowController = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     )..repeat(reverse: true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Glow Effect
//         AnimatedBuilder(
//           animation: _glowController,
//           builder: (context, child) {
//             return Container(
//               width: 40.w,
//               height: 40.h,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.purpleAccent.withOpacity(
//                   _glowController.value * 0.3,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.purpleAccent.withOpacity(
//                       _glowController.value * 0.5,
//                     ),
//                     blurRadius: 15,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),

//         // Icon Button
//         IconButton(
//           icon: Icon(widget.icon, color: Colors.white, size: 24.sp),
//           onPressed: widget.onTap,
//         ),

//         // Badge
//         if (widget.badge)
//           Positioned(
//             top: 8.h,
//             right: 8.w,
//             child: Container(
//               width: 12.w,
//               height: 12.h,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.redAccent,
//                 border: Border.all(color: Colors.white, width: 1.5),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class _SocialIcon extends StatelessWidget {
//   final IconData icon;
//   final Color color;

//   const _SocialIcon({required this.icon, this.color = Colors.white});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 44.w,
//       height: 44.h,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: color.withOpacity(0.1),
//         border: Border.all(color: color.withOpacity(0.3), width: 1),
//       ),
//       child: Icon(icon, color: color, size: 20.w),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:jj_app/app/presentation/cloudNotificationScreen/cloud_notification_screen.dart';
// import 'package:jj_app/app/presentation/profile/profile_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF8F9FA),
//       body: CustomScrollView(
//         physics: BouncingScrollPhysics(),
//         slivers: [
//           // 1. App Bar with Animated Icons
//           SliverAppBar(
//             expandedHeight: 90.h,
//             floating: true,
//             pinned: true,
//             snap: true,
//             stretch: true,
//             backgroundColor: Colors.white,
//             title: Text(
//               'Journey Junction',
//               style: TextStyle(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.w800,
//                 color: Color(0xFF2A2B2E),
//                 letterSpacing: 1.5,
//               ),
//             ),
//             centerTitle: true,
//             actions: [
//               _AnimatedIconButton(
//                 icon: Icons.notifications_outlined,
//                 badge: true,
//                 onTap: () => Get.to(() => CloudNotificationScreen()),
//               ),
//               SizedBox(width: 8.w),
//               _AnimatedIconButton(
//                 icon: Icons.person_outline,
//                 onTap: () => Get.to(() => ProfileScreen()),
//               ),
//               SizedBox(width: 12.w),
//             ],
//           ),

//           // 2. Hero Carousel
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 280.h,
//               child: PageView.builder(
//                 itemCount: 3,
//                 controller: PageController(viewportFraction: 0.92),
//                 padEnds: false,
//                 itemBuilder: (_, index) {
//                   final images = [
//                     'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
//                     'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
//                     'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
//                   ];
//                   return Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 16.h,
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(24.r),
//                       child: Stack(
//                         children: [
//                           Image.network(
//                             images[index],
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                           ),
//                           Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   Colors.transparent,
//                                   Colors.black.withOpacity(0.7),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 20.h,
//                             left: 20.w,
//                             right: 20.w,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   [
//                                     'Himalayan Retreat',
//                                     'Goa Beaches',
//                                     'Rajasthan Forts',
//                                   ][index],
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 22.sp,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Text(
//                                   [
//                                     'Luxury mountain resorts',
//                                     'Golden sand beaches',
//                                     'Royal heritage palaces',
//                                   ][index],
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.9),
//                                     fontSize: 16.sp,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           // 3. Quick Categories (Micro-interactions)
//           SliverPadding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//             sliver: SliverGrid(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 childAspectRatio: 0.8,
//                 mainAxisSpacing: 12.h,
//                 crossAxisSpacing: 12.w,
//               ),
//               delegate: SliverChildBuilderDelegate((_, index) {
//                 final categories = [
//                   {'icon': '⛰️', 'label': 'Mountains'},
//                   {'icon': '🏖️', 'label': 'Beaches'},
//                   {'icon': '🏛️', 'label': 'Heritage'},
//                   {'icon': '🏕️', 'label': 'Camping'},
//                   {'icon': '🍜', 'label': 'Food'},
//                   {'icon': '🛕', 'label': 'Spiritual'},
//                   {'icon': '🛒', 'label': 'Shopping'},
//                   {'icon': '🎭', 'label': 'Culture'},
//                 ];
//                 return _CategoryCard(
//                   emoji: categories[index]['icon']!,
//                   label: categories[index]['label']!,
//                 );
//               }, childCount: 8),
//             ),
//           ),

//           // 4. Trending Stories (3D Cards)
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(left: 20.w, top: 20.h, bottom: 10.h),
//               child: Text(
//                 'TRENDING STORIES',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF2A2B2E),
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 240.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.only(left: 20.w, right: 20.w),
//                 itemCount: 4,
//                 itemBuilder: (_, index) {
//                   return Transform(
//                     transform:
//                         Matrix4.identity()
//                           ..setEntry(3, 2, 0.002)
//                           ..rotateX(0.01),
//                     alignment: Alignment.center,
//                     child: Container(
//                       width: 180.w,
//                       margin: EdgeInsets.only(right: 16.w),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20.r),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 20,
//                             spreadRadius: 2,
//                             offset: Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(20.r),
//                             ),
//                             child: Image.network(
//                               [
//                                 'https://images.unsplash.com/photo-1582972236019-ea9dfa7b0c9c',
//                                 'https://images.unsplash.com/photo-1527631746610-bca00a040d60',
//                                 'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
//                                 'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
//                               ][index],
//                               height: 120.h,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Padding(
//                             padding: EdgeInsets.all(12.w),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   [
//                                     'Monsoon Magic',
//                                     'Desert Nights',
//                                     'Backwaters',
//                                     'Himalayan Trek',
//                                   ][index],
//                                   style: TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 SizedBox(height: 6.h),
//                                 Row(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 12.r,
//                                       backgroundImage: NetworkImage(
//                                         'https://randomuser.me/api/portraits/men/${index + 10}.jpg',
//                                       ),
//                                     ),
//                                     SizedBox(width: 8.w),
//                                     Text(
//                                       'By ${['Rahul', 'Priya', 'Arjun', 'Meera'][index]}',
//                                       style: TextStyle(
//                                         fontSize: 12.sp,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 10.h),
//                                 Row(
//                                   children: [
//                                     Icon(
//                                       Icons.favorite_border,
//                                       size: 16.w,
//                                       color: Colors.grey,
//                                     ),
//                                     SizedBox(width: 4.w),
//                                     Text(
//                                       '1.2K',
//                                       style: TextStyle(fontSize: 12.sp),
//                                     ),
//                                     Spacer(),
//                                     Text(
//                                       '3 min read',
//                                       style: TextStyle(
//                                         fontSize: 10.sp,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           // 5. Premium Destinations
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(left: 20.w, top: 30.h, bottom: 10.h),
//               child: Text(
//                 'PREMIUM DESTINATIONS',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF2A2B2E),
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ),
//           ),
//           SliverPadding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w),
//             sliver: SliverGrid(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 1.2,
//                 mainAxisSpacing: 16.h,
//                 crossAxisSpacing: 16.w,
//               ),
//               delegate: SliverChildBuilderDelegate((_, index) {
//                 return _DestinationCard(
//                   image:
//                       [
//                         'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
//                         'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
//                         'https://images.unsplash.com/photo-1464037866556-6812c9d1c72e',
//                         'https://images.unsplash.com/photo-1582972236019-ea9dfa7b0c9c',
//                       ][index],
//                   title: ['Udaipur', 'Kerala', 'Ladakh', 'Varanasi'][index],
//                   subtitle:
//                       ['Palaces', 'Backwaters', 'Mountains', 'Ghats'][index],
//                 );
//               }, childCount: 4),
//             ),
//           ),

//           // 6. Testimonials (Parallax)
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(left: 20.w, top: 40.h, bottom: 10.h),
//               child: Text(
//                 'TRAVELER STORIES',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF2A2B2E),
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 200.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.only(left: 20.w, right: 20.w),
//                 itemCount: 3,
//                 itemBuilder: (_, index) {
//                   return Container(
//                     width: 300.w,
//                     margin: EdgeInsets.only(right: 16.w),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20.r),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 20,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(20.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 20.r,
//                                 backgroundImage: NetworkImage(
//                                   'https://randomuser.me/api/portraits/women/${index + 20}.jpg',
//                                 ),
//                               ),
//                               SizedBox(width: 12.w),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     ['Ananya', 'Priya', 'Riya'][index],
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16.sp,
//                                     ),
//                                   ),
//                                   Text(
//                                     'Travel Enthusiast',
//                                     style: TextStyle(
//                                       fontSize: 12.sp,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 16.h),
//                           Expanded(
//                             child: Text(
//                               [
//                                 'The cultural insights made my Rajasthan trip unforgettable. Found hidden gems through this app!',
//                                 'Never would have discovered those secret beaches without Wanderluxe recommendations.',
//                                 'Met amazing local guides who showed me the real India beyond tourist spots.',
//                               ][index],
//                               style: TextStyle(fontSize: 14.sp, height: 1.5),
//                               maxLines: 4,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           // 7. Footer
//           SliverToBoxAdapter(
//             child: Container(
//               margin: EdgeInsets.only(top: 40.h),
//               padding: EdgeInsets.symmetric(vertical: 30.h),
//               decoration: BoxDecoration(
//                 color: Color(0xFF2A2B2E),
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     'Journey Junction',
//                     style: TextStyle(
//                       fontSize: 24.sp,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     'Discover the extraordinary',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _SocialIcon(icon: Icons.facebook),
//                       SizedBox(width: 20.w),
//                       _SocialIcon(icon: Icons.inbox),
//                       SizedBox(width: 20.w),
//                       _SocialIcon(icon: Icons.one_x_mobiledata),
//                     ],
//                   ),
//                   SizedBox(height: 24.h),
//                   Text(
//                     '© 2025 JourneyJunction. All rights reserved.',
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.white.withOpacity(0.5),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Custom Widgets
// class _AnimatedIconButton extends StatefulWidget {
//   final IconData icon;
//   final bool badge;
//   final VoidCallback onTap;

//   const _AnimatedIconButton({
//     required this.icon,
//     this.badge = false,
//     required this.onTap,
//   });

//   @override
//   __AnimatedIconButtonState createState() => __AnimatedIconButtonState();
// }

// class __AnimatedIconButtonState extends State<_AnimatedIconButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 200),
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.8,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) {
//         _controller.reverse();
//         widget.onTap();
//       },
//       onTapCancel: () => _controller.reverse(),
//       child: ScaleTransition(
//         scale: _scaleAnimation,
//         child: Stack(
//           alignment: Alignment.topRight,
//           children: [
//             Container(
//               width: 40.w,
//               height: 40.h,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xFF2A2B2E).withOpacity(0.05),
//               ),
//               child: Icon(widget.icon, size: 22.w, color: Color(0xFF2A2B2E)),
//             ),
//             if (widget.badge)
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 child: Container(
//                   width: 16.w,
//                   height: 16.h,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Color(0xFFFF4757),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '1',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 10.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CategoryCard extends StatelessWidget {
//   final String emoji;
//   final String label;

//   const _CategoryCard({required this.emoji, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16.r),
//           onTap: () {},
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(emoji, style: TextStyle(fontSize: 28.sp)),
//               SizedBox(height: 8.h),
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ),

//     );
//   }
// }

// class _DestinationCard extends StatelessWidget {
//   final String image;
//   final String title;
//   final String subtitle;

//   const _DestinationCard({
//     required this.image,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16.r),
//       child: Stack(
//         children: [
//           Image.network(
//             image,
//             fit: BoxFit.cover,
//             height: double.infinity,
//             width: double.infinity,
//           ),
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//               ),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 14.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SocialIcon extends StatelessWidget {
//   final IconData icon;

//   const _SocialIcon({required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 40.w,
//       height: 40.h,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white.withOpacity(0.1),
//       ),
//       child: Icon(icon, color: Colors.white, size: 20.w),
//     );
//   }
// }
