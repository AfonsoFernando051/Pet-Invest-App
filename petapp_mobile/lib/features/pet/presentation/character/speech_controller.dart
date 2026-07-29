/// Speech Controller subsystem — Phase 1+ extension point, not wired into
/// the UI yet. Today `CharacterEngine.currentLine` is shown silently in a
/// `CharacterSpeechBubble`. Once a TTS provider is chosen (Google TTS,
/// Gemini TTS, OpenAI TTS, Azure Speech, ElevenLabs, Cartesia — see
/// docs/CHARACTER_ENGINE.md), it should implement this interface so the
/// provider can be swapped without touching `CharacterEngine` or the
/// mascot widget.
abstract class SpeechController {
  Future<void> speak(String line);

  Future<void> stop();
}
