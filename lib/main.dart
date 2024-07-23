import 'package:flutter/material.dart';
import 'package:us_hub/core/global_colors.dart';
import 'package:us_hub/core/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Arimo',
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: GlobalColors.primaryColor,
          onPrimary: GlobalColors.primaryFgColor,
          secondary: GlobalColors.secondaryColor,
          onSecondary: GlobalColors.secondaryFgColor,
          tertiary: GlobalColors.accentColor,
          onTertiary: GlobalColors.accentFgColor,
          surface: GlobalColors.backgroundColor,
          onSurface: GlobalColors.textColor,
          error: Color(0xffF2B8B5),
          onError: Color(0xff601410),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
