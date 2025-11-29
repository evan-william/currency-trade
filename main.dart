// FILE: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:currency_changer/main_nav.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.tealAccent,
        brightness: Brightness.dark,
        primary: Colors.tealAccent,
        secondary: Colors.teal,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
      navigationBarTheme: NavigationBarThemeData(
        // [FIXED] Menggunakan WidgetStateProperty
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          // [FIXED] Menggunakan WidgetState
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Colors.tealAccent
            );
          }
          return GoogleFonts.inter(
            fontSize: 12, 
            fontWeight: FontWeight.normal, 
            color: Colors.grey
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey[700]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    return MaterialApp(
      title: 'Currency Switcher',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainNavScreen(), 
    );
  }
}