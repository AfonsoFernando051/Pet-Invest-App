import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/models/question_model.dart';
import '../widgets/question_card.dart';
import '../widgets/submit_assessment_button.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
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
    return FutureBuilder<List<QuestionModel>>(
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
    );
  }
}
