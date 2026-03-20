import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/di/dependency_injection.dart';
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

    // Ensure every question has one selected option.
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
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Investor Profile', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.backgroundMedium,
        elevation: 0,
      ),
      body: FutureBuilder<List<QuestionModel>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load questions: ${snapshot.error}'));
          }
          final questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return const Center(child: Text('No questions available.'));
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return _QuestionCard(
                          question: q,
                          selectedOptionId: _selectedOptionByQuestionId[q.id],
                          onSelected: (optionId) {
                            setState(() => _selectedOptionByQuestionId[q.id] = optionId);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _handleSubmit(questions),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.primaryButton,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final String? selectedOptionId;
  final ValueChanged<String> onSelected;

  const _QuestionCard({
    required this.question,
    required this.selectedOptionId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...question.options.map(
            (o) => RadioListTile<String>(
              title: Text(o.text, style: const TextStyle(color: AppColors.white70)),
              value: o.id,
              // ignore: deprecated_member_use
              groupValue: selectedOptionId,
              // ignore: deprecated_member_use
              onChanged: (value) {
                if (value == null) return;
                onSelected(value);
              },
              activeColor: AppColors.primaryButton,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

