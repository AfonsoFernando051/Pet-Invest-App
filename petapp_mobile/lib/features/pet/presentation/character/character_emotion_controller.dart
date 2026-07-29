import 'package:flutter/material.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/features/pet/domain/character/character_event.dart';
import 'package:petapp_mobile/features/pet/domain/enums/character_emotion.dart';

/// How the current [CharacterEmotion] should color/pace the mascot's
/// *existing* visual layers (aura, breathe speed, tap-bump reaction) — a
/// stand-in for the dedicated per-emotion face art drawn in
/// `assets/pets/*.png` until that reference sheet is sliced into real
/// per-emotion Lottie/PNG assets (see `CharacterEmotion`'s doc comment).
@immutable
class EmotionVisualProfile {
  const EmotionVisualProfile({
    required this.auraColor,
    required this.breatheSpeedMultiplier,
    required this.bumpIntensityMultiplier,
    required this.sparkle,
  });

  final Color auraColor;

  /// Multiplies the mascot's breathe-cycle speed (>1 = faster/more alert,
  /// <1 = slower/calmer).
  final double breatheSpeedMultiplier;

  /// Multiplies the tap-reaction bump distance (>1 = bigger reaction).
  final double bumpIntensityMultiplier;

  /// Whether the aura should render its celebratory sparkle treatment.
  final bool sparkle;
}

/// Emotion Controller subsystem of the Character Engine: tracks the
/// mascot's current [CharacterEmotion] and exposes the [EmotionVisualProfile]
/// derived from it. Independent of `MascotController`'s animation-state
/// machine — the same `idle` clip should look calmer when [emotion] is
/// [CharacterEmotion.neutral] and more alert when it's [CharacterEmotion.excited].
class CharacterEmotionController extends ChangeNotifier {
  CharacterEmotion _emotion = CharacterEmotion.neutral;

  CharacterEmotion get emotion => _emotion;
  EmotionVisualProfile get visualProfile => profileFor(_emotion);

  void setEmotion(CharacterEmotion emotion) {
    if (_emotion == emotion) return;
    _emotion = emotion;
    notifyListeners();
  }

  /// Maps an app-level [CharacterEventType] to the emotion it should evoke.
  void reactTo(CharacterEventType type) => setEmotion(emotionFor(type));

  static CharacterEmotion emotionFor(CharacterEventType type) {
    switch (type) {
      case CharacterEventType.achievementUnlocked:
        return CharacterEmotion.proud;
      case CharacterEventType.stageEvolved:
        return CharacterEmotion.veryHappy;
      case CharacterEventType.userReturned:
        return CharacterEmotion.love;
      case CharacterEventType.missionCompleted:
        return CharacterEmotion.playful;
      case CharacterEventType.portfolioAllTimeHigh:
        return CharacterEmotion.excited;
      case CharacterEventType.portfolioSignificantDrop:
        return CharacterEmotion.sad;
      case CharacterEventType.dividendReceived:
        return CharacterEmotion.happy;
      case CharacterEventType.goalAchieved:
        return CharacterEmotion.motivated;
    }
  }

  static EmotionVisualProfile profileFor(CharacterEmotion emotion) {
    switch (emotion) {
      case CharacterEmotion.neutral:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonCyan,
          breatheSpeedMultiplier: 0.9,
          bumpIntensityMultiplier: 0.9,
          sparkle: false,
        );
      case CharacterEmotion.happy:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonCyan,
          breatheSpeedMultiplier: 1.1,
          bumpIntensityMultiplier: 1.0,
          sparkle: false,
        );
      case CharacterEmotion.veryHappy:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPink,
          breatheSpeedMultiplier: 1.3,
          bumpIntensityMultiplier: 1.2,
          sparkle: true,
        );
      case CharacterEmotion.laughing:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPink,
          breatheSpeedMultiplier: 1.3,
          bumpIntensityMultiplier: 1.2,
          sparkle: true,
        );
      case CharacterEmotion.curious:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonBlue,
          breatheSpeedMultiplier: 1.0,
          bumpIntensityMultiplier: 1.0,
          sparkle: false,
        );
      case CharacterEmotion.thinking:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonViolet,
          breatheSpeedMultiplier: 0.9,
          bumpIntensityMultiplier: 0.7,
          sparkle: false,
        );
      case CharacterEmotion.determined:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonBlue,
          breatheSpeedMultiplier: 1.0,
          bumpIntensityMultiplier: 1.0,
          sparkle: false,
        );
      case CharacterEmotion.confident:
        return const EmotionVisualProfile(
          auraColor: AppColors.goldenBorder,
          breatheSpeedMultiplier: 1.05,
          bumpIntensityMultiplier: 1.0,
          sparkle: false,
        );
      case CharacterEmotion.proud:
        return const EmotionVisualProfile(
          auraColor: AppColors.goldenBorder,
          breatheSpeedMultiplier: 1.1,
          bumpIntensityMultiplier: 1.1,
          sparkle: true,
        );
      case CharacterEmotion.excited:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPink,
          breatheSpeedMultiplier: 1.4,
          bumpIntensityMultiplier: 1.3,
          sparkle: true,
        );
      case CharacterEmotion.motivated:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonViolet,
          breatheSpeedMultiplier: 1.2,
          bumpIntensityMultiplier: 1.1,
          sparkle: true,
        );
      case CharacterEmotion.surprised:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPink,
          breatheSpeedMultiplier: 1.5,
          bumpIntensityMultiplier: 1.4,
          sparkle: false,
        );
      case CharacterEmotion.confused:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPurple,
          breatheSpeedMultiplier: 1.0,
          bumpIntensityMultiplier: 0.9,
          sparkle: false,
        );
      case CharacterEmotion.embarrassed:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPurple,
          breatheSpeedMultiplier: 0.9,
          bumpIntensityMultiplier: 0.8,
          sparkle: false,
        );
      case CharacterEmotion.sad:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonBlue,
          breatheSpeedMultiplier: 0.7,
          bumpIntensityMultiplier: 0.6,
          sparkle: false,
        );
      case CharacterEmotion.crying:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonBlue,
          breatheSpeedMultiplier: 0.6,
          bumpIntensityMultiplier: 0.5,
          sparkle: false,
        );
      case CharacterEmotion.sleepy:
        return const EmotionVisualProfile(
          auraColor: AppColors.spaceBlue,
          breatheSpeedMultiplier: 0.6,
          bumpIntensityMultiplier: 0.4,
          sparkle: false,
        );
      case CharacterEmotion.sleeping:
        return const EmotionVisualProfile(
          auraColor: AppColors.spaceBlue,
          breatheSpeedMultiplier: 0.5,
          bumpIntensityMultiplier: 0.3,
          sparkle: false,
        );
      case CharacterEmotion.love:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPink,
          breatheSpeedMultiplier: 1.15,
          bumpIntensityMultiplier: 1.1,
          sparkle: true,
        );
      case CharacterEmotion.scared:
        return const EmotionVisualProfile(
          auraColor: AppColors.warningAmber,
          breatheSpeedMultiplier: 1.3,
          bumpIntensityMultiplier: 1.2,
          sparkle: false,
        );
      case CharacterEmotion.dizzy:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPurple,
          breatheSpeedMultiplier: 1.2,
          bumpIntensityMultiplier: 0.9,
          sparkle: false,
        );
      case CharacterEmotion.sick:
        return const EmotionVisualProfile(
          auraColor: AppColors.warningAmber,
          breatheSpeedMultiplier: 0.7,
          bumpIntensityMultiplier: 0.5,
          sparkle: false,
        );
      case CharacterEmotion.shocked:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonPurple,
          breatheSpeedMultiplier: 1.5,
          bumpIntensityMultiplier: 1.3,
          sparkle: false,
        );
      case CharacterEmotion.angry:
        return const EmotionVisualProfile(
          auraColor: AppColors.warningAmber,
          breatheSpeedMultiplier: 1.2,
          bumpIntensityMultiplier: 1.1,
          sparkle: false,
        );
      case CharacterEmotion.playful:
        return const EmotionVisualProfile(
          auraColor: AppColors.neonCyan,
          breatheSpeedMultiplier: 1.2,
          bumpIntensityMultiplier: 1.2,
          sparkle: true,
        );
    }
  }
}
