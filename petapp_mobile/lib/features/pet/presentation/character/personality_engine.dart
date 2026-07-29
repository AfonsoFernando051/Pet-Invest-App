import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';
import 'package:petapp_mobile/features/pet/domain/character/character_event.dart';

/// Personality Engine subsystem: the same event or greeting should sound
/// different depending on the mascot's [PetSpecieEnum] — dog is playful and
/// energetic, wolf is serious and protective, and so on (see the brief's
/// "Personality Engine" section). This is a template-based stand-in for what
/// will eventually be a per-species system-prompt fragment handed to an
/// `AiBrain` (Phase 1+, see docs/CHARACTER_ENGINE.md) — the interface is
/// shaped so that swap is additive, not a rewrite.
abstract class PersonalityEngine {
  /// A short in-character line reacting to [event], flavored by [species].
  String phraseFor(CharacterEventType event, PetSpecieEnum species);

  /// A "welcome back" line after the player was away for [daysAway] days,
  /// flavored by [species] and using [petName] when the player has already
  /// named their pet.
  String greetingFor(PetSpecieEnum species, {required int daysAway, String? petName});
}

class DefaultPersonalityEngine implements PersonalityEngine {
  const DefaultPersonalityEngine();

  @override
  String phraseFor(CharacterEventType event, PetSpecieEnum species) {
    final bank = _phrases[species] ?? _phrases[PetSpecieEnum.DOG]!;
    return bank[event] ?? _fallback[event] ?? 'Estou aqui com você!';
  }

  @override
  String greetingFor(PetSpecieEnum species, {required int daysAway, String? petName}) {
    final template = _greetings[species] ?? _greetings[PetSpecieEnum.DOG]!;
    final name = petName == null || petName.isEmpty ? '' : ' $petName';
    return template(daysAway).replaceFirst('{name}', name);
  }

  static const Map<CharacterEventType, String> _fallback = {
    CharacterEventType.achievementUnlocked: 'Conquista desbloqueada! Muito bem!',
    CharacterEventType.stageEvolved: 'Uau, eu evoluí!',
    CharacterEventType.missionCompleted: 'Missão concluída!',
  };

  static final Map<PetSpecieEnum, Map<CharacterEventType, String>> _phrases = {
    PetSpecieEnum.DOG: {
      CharacterEventType.achievementUnlocked: 'Auau! Você conseguiu! Estou pulando de alegria! 🐾',
      CharacterEventType.stageEvolved: 'Eba eba eba! Olha só no que eu virei!',
      CharacterEventType.missionCompleted: 'Missão completa! Bora pra próxima?',
    },
    PetSpecieEnum.CAT: {
      CharacterEventType.achievementUnlocked: 'Hmpf... nada mal. Estou orgulhoso, mesmo que não pareça.',
      CharacterEventType.stageEvolved: 'Eu já sabia que ia evoluir. Óbvio.',
      CharacterEventType.missionCompleted: 'Missão feita. Como esperado de mim.',
    },
    PetSpecieEnum.WOLF: {
      CharacterEventType.achievementUnlocked: 'Disciplina reconhecida. Continue assim.',
      CharacterEventType.stageEvolved: 'Mais forte. Mais preparado. Vamos em frente.',
      CharacterEventType.missionCompleted: 'Objetivo cumprido. Próximo passo.',
    },
    PetSpecieEnum.FOX: {
      CharacterEventType.achievementUnlocked: 'Esperto como sempre! Essa jogada valeu a pena.',
      CharacterEventType.stageEvolved: 'Nova forma, nova estratégia. Adorei.',
      CharacterEventType.missionCompleted: 'Missão resolvida com estilo!',
    },
    PetSpecieEnum.BEAR: {
      CharacterEventType.achievementUnlocked: 'Passo a passo, com calma. Você chegou lá.',
      CharacterEventType.stageEvolved: 'Crescimento sólido. Sem pressa, sem parar.',
      CharacterEventType.missionCompleted: 'Mais uma missão concluída, com calma e firmeza.',
    },
    PetSpecieEnum.LION: {
      CharacterEventType.achievementUnlocked: 'Essa é a atitude de um verdadeiro líder!',
      CharacterEventType.stageEvolved: 'Eu foi feito para isso. Vamos liderar juntos.',
      CharacterEventType.missionCompleted: 'Missão vencida! Lidere a próxima também!',
    },
  };

  static final Map<PetSpecieEnum, String Function(int)> _greetings = {
    PetSpecieEnum.DOG: (days) => days <= 1
        ? 'Que bom te ver de novo!{name}'
        : 'Senti MUITO a sua falta! Fiquei $days dias esperando você!{name}',
    PetSpecieEnum.CAT: (days) => days <= 1
        ? 'Ah, você voltou.{name}'
        : 'Levou $days dias, mas tudo bem, eu esperei.{name}',
    PetSpecieEnum.WOLF: (days) => days <= 1
        ? 'De volta ao trabalho.{name}'
        : '$days dias de ausência. Vamos retomar o rumo.{name}',
    PetSpecieEnum.FOX: (days) => days <= 1
        ? 'Voltou bem na hora!{name}'
        : '$days dias parado... vamos recuperar o tempo perdido.{name}',
    PetSpecieEnum.BEAR: (days) => days <= 1
        ? 'Bom te ver por aqui de novo.{name}'
        : 'Ficamos $days dias parados, mas sem problema. Vamos continuar juntos.{name}',
    PetSpecieEnum.LION: (days) => days <= 1
        ? 'A liderança está de volta!{name}'
        : '$days dias longe do trono... hora de retomar o comando!{name}',
  };
}
