import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/login_background.dart';
import 'package:petapp_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:petapp_mobile/features/onboarding/data/models/question_model.dart';
import 'package:petapp_mobile/features/onboarding/presentation/widgets/question_card.dart';
import 'package:petapp_mobile/features/onboarding/presentation/widgets/submit_assessment_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late Future<List<QuestionModel>> _questionsFuture;
  final Map<String, String> _selectedOptionByQuestionId = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questionsFuture = DI.onboardingRepository.getQuestions();
  }

  Future<void> _handleSubmit(List<QuestionModel> questions) async {
    if (_isSubmitting) return;

    final selectedOptionIds = <String>[];
    for (final q in questions) {
      final selected = _selectedOptionByQuestionId[q.id];
      if (selected == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please answer all questions')),
        );
        return;
      }
      selectedOptionIds.add(selected);
    }

    setState(() => _isSubmitting = true);
    try {
      await DI.onboardingRepository.submitAssessment(selectedOptionIds);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Onboarding failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceDark, // Update to spaceDark
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Seu Perfil de Investidor Pet',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          const LoginBackground(),
          SafeArea(
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
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background graphic inside the card
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.4,
                          child: Image.asset(
                            'assets/images/questionary_space_paw.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: FutureBuilder<List<QuestionModel>>(
                          future: _questionsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
                              );
                            }
                            if (snapshot.hasError) {
                              return SizedBox(
                                height: 300,
                                child: Center(
                                  child: Text(
                                    'Failed to load questions: ${snapshot.error}',
                                    style: const TextStyle(color: Colors.white),
                                  )
                                ),
                              );
                            }
                            final questions = snapshot.data ?? [];
                            if (questions.isEmpty) {
                              return const SizedBox(
                                height: 300,
                                child: Center(
                                  child: Text('No questions available.', style: TextStyle(color: Colors.white))
                                ),
                              );
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...questions.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final q = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: QuestionCard(
                                      question: q,
                                      isFirst: index == 0,
                                      selectedOptionId: _selectedOptionByQuestionId[q.id],
                                      onSelected: (optionId) {
                                        setState(() => _selectedOptionByQuestionId[q.id] = optionId);
                                      },
                                    ),
                                  );
                                }),
                                
                                const SizedBox(height: 8),
                                
                                // Submit Button
                                SubmitAssessmentButton(
                                  isSubmitting: _isSubmitting,
                                  onPressed: () => _handleSubmit(questions),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Esqueceu as respostas?',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      
                      // Bottom right star decoration - moved inside the card
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: Icon(
                          Icons.auto_awesome, 
                          color: Colors.white.withValues(alpha: 0.6),
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
        ],
      ),
    );
  }
}

