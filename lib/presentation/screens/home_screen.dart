import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'camera_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'ngo_home_tab.dart';
import 'ngo_profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _donorTabIndex = 0;
  int _ngoTabIndex = 0;
  bool _isNgoMode = false;

  final List<Widget> _donorTabs = const [
    HomeTab(),
    CameraTab(),
    ProfileTab(),
  ];

  final List<Widget> _ngoTabs = const [
    NgoHomeTab(),
    NgoProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _isNgoMode ? _ngoTabIndex : _donorTabIndex;
    final currentTitle = _isNgoMode 
        ? (currentIndex == 0 ? 'Incoming Donations' : 'NGO Profile')
        : (currentIndex == 0 ? 'Nearby NGOs' : (currentIndex == 1 ? 'Scan Item' : 'Donor Profile'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(currentTitle, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // prevents color change on scroll
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Row(
            children: [
              const Text('NGO Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
              Switch(
                value: _isNgoMode,
                activeColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (val) {
                  setState(() {
                    _isNgoMode = val;
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isNgoMode ? _ngoTabs[_ngoTabIndex] : _donorTabs[_donorTabIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              if (_isNgoMode) {
                _ngoTabIndex = index;
              } else {
                _donorTabIndex = index;
              }
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: Colors.white,
          elevation: 0,
          items: _isNgoMode
              ? const [
                  BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Donations'),
                  BottomNavigationBarItem(icon: Icon(Icons.domain), label: 'Profile'),
                ]
              : const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camera'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
        ),
      ),
    );
  }
}