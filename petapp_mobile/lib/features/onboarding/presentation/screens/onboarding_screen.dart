import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
import 'package:petapp_mobile/features/auth/presentation/widgets/login_background.dart';
import 'package:petapp_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:petapp_mobile/features/onboarding/data/models/question_model.dart';

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
                                    child: _QuestionCard(
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
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF8E2DE2), AppColors.neonCyan],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF8E2DE2).withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : () => _handleSubmit(questions),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'Enviar Respostas',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
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

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final String? selectedOptionId;
  final ValueChanged<String> onSelected;
  final bool isFirst;

  const _QuestionCard({
    required this.question,
    required this.selectedOptionId,
    required this.onSelected,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E36).withValues(alpha: 0.7), // Glassmorphism dark background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFirst) ...[
                // Custom Compass/Paw icon for the first question like the mock
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.explore, color: Colors.blueGrey, size: 28),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(Icons.pets, color: Colors.brown[300], size: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...question.options.map((o) {
            final isSelected = selectedOptionId == o.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () => onSelected(o.id),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.neonCyan : Colors.white38,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.neonCyan.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                Icons.pets,
                                size: 14,
                                color: AppColors.neonCyan,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        o.text,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
