// FILE: lib/main_nav.dart

import 'package:flutter/material.dart';
import 'package:currency_changer/features/converter/screens/converter_screen.dart';
import 'package:currency_changer/features/news/screens/news_screen.dart';
// [FIXED] Hapus import google_fonts yang tidak terpakai

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ConverterScreen(),
    const NewsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar state halaman tidak hilang saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF333333), width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: const Color(0xFF121212),
          // [FIXED] Menggunakan withValues(alpha: ...)
          indicatorColor: Colors.tealAccent.withValues(alpha: 0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.currency_exchange_rounded),
              selectedIcon: Icon(Icons.currency_exchange_rounded, color: Colors.tealAccent),
              label: 'Converter',
            ),
            NavigationDestination(
              icon: Icon(Icons.newspaper_rounded),
              selectedIcon: Icon(Icons.newspaper_rounded, color: Colors.tealAccent),
              label: 'News',
            ),
          ],
        ),
      ),
    );
  }
}