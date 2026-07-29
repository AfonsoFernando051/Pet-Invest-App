import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';

/// AI Brain subsystem — Phase 1+ extension point, not wired into the UI yet.
///
/// Today the mascot's reactions come from `PersonalityEngine`'s canned,
/// species-flavored templates. When an LLM-backed brain is ready (reusing
/// the same Gemini backend the Mentor chat already calls — see
/// `GeminiChatClient` — rather than a second provider), it should implement
/// this interface so `CharacterEngine` can swap template lines for generated
/// ones without any other subsystem changing. The contract deliberately
/// mirrors `PersonalityEngine.phraseFor`: species in, in-character line out.
/// The LLM must always respond as the pet, never as a generic assistant.
abstract class AiBrain {
  Future<String> composeLine({
    required String situation,
    required PetSpecieEnum species,
    String? petName,
  });
}
