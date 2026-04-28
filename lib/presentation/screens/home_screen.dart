import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'camera_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'ngo_home_tab.dart';
import 'ngo_profile_tab.dart';
import 'messages_tab.dart';

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
    MessagesTab(isNgoMode: false),
    ProfileTab(),
  ];

  final List<Widget> _ngoTabs = const [
    NgoHomeTab(),
    MessagesTab(isNgoMode: true),
    NgoProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _isNgoMode ? _ngoTabIndex : _donorTabIndex;
    final currentTitle = _isNgoMode 
        ? (currentIndex == 0 ? 'Incoming Donations' : (currentIndex == 1 ? 'Messages' : 'NGO Profile'))
        : (currentIndex == 0 ? 'Nearby NGOs' : (currentIndex == 1 ? 'Scan Item' : (currentIndex == 2 ? 'Messages' : 'Donor Profile')));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(currentTitle, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, letterSpacing: -0.5, fontSize: 24)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('NGO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54)),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
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
                ),
              ],
            ),
          ),
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
          type: BottomNavigationBarType.fixed,
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
                  BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
                  BottomNavigationBarItem(icon: Icon(Icons.domain), label: 'Profile'),
                ]
              : const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Camera'),
                  BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
        ),
      ),
    );
  }
}