import 'package:flutter/material.dart';
import 'package:new_flutter_app/app/core/constants/constdata.dart';
import 'package:new_flutter_app/app/core/utils/app_styles.dart';
import 'package:new_flutter_app/app/presentation/community/community_screen.dart';
import 'package:new_flutter_app/app/presentation/explore/explore_screen.dart';
import 'package:new_flutter_app/app/presentation/home/home_screen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen>
    with TickerProviderStateMixin {
  int _currentTab = 0;
  late List<AnimationController> _scaleControllers;

  @override
  void initState() {
    super.initState();
    _scaleControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      )..addListener(() => setState(() {})),
    );
    _scaleControllers[_currentTab].value = 1.0;
  }

  @override
  void dispose() {
    for (var controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onTap: () => _handleTabChange(1)),
      const ExploreScreen(),
      const CommunityScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentTab, children: pages),
      bottomNavigationBar: _buildBubbleTabBar(),
    );
  }

  Widget _buildBubbleTabBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(0, Icons.home_outlined, 'Home'),
          _buildTabItem(1, Icons.explore_outlined, 'Explore'),
          _buildTabItem(2, Icons.people_outlined, 'Community'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isActive = _currentTab == index;
    final scale = _scaleControllers[index].value * 0.2 + 0.8;

    return GestureDetector(
      onTap: () => _handleTabChange(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                ScaleTransition(
                  scale: _scaleControllers[index],
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: kSecondary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              // Icon with scale animation
              Transform.scale(
                scale: scale,
                child: Icon(
                  icon,
                  color: isActive ? kSecondary : kGray,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: appStyle(
              12,
              isActive ? kSecondary : kGray,
              isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabChange(int index) {
    if (_currentTab == index) return;

    setState(() {
      // Reset current tab animation
      _scaleControllers[_currentTab].reverse();
      _currentTab = index;
      // Animate new tab
      _scaleControllers[index].forward();
    });
  }
}
