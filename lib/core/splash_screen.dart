import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:us_hub/core/global_colors.dart';
import 'package:us_hub/pages/home_screen.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  get splash => null;

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: GlobalColors.backgroundColor,
      splash: Column(
        children: [
          Center(
            child: LottieBuilder.asset(
              'assets/splash.json',
            ),
          )
        ],
      ),
      duration: 1600,
      pageTransitionType: PageTransitionType.fade,
      splashIconSize: MediaQuery.of(context).size.height / 2,
      nextScreen: const HomeScreen(),
    );
  }
}
