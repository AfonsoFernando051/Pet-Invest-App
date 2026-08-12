import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';
import 'package:petrimonium/features/onboarding/presentation/widgets/onboarding_form.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    return Scaffold(
      backgroundColor: tokens.backgroundPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Seu Perfil de Investidor Pet',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: tokens.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: tokens.surface.withValues(alpha: context.isDarkMode ? 0.06 : 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: tokens.border),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadow,
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Subtle watermark — single layer, low opacity
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: Image.asset(
                            'assets/images/questionary_space_paw.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.topRight,
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: const OnboardingForm(),
                      ),
                      
                      // Bottom right star decoration - moved inside the card
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Icon(
                          Icons.auto_awesome,
                          color: tokens.textPrimary.withValues(alpha: 0.6),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

