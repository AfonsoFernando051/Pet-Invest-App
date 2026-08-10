import 'dart:io';

/// Maps a caught error into copy that's safe and clear to show a user —
/// never the raw `Exception: ...` text, and something more useful than that
/// for the most common failure (no connectivity).
String friendlyErrorMessage(Object error) {
  if (error is SocketException) {
    return 'Não foi possível conectar. Verifique sua internet e tente novamente.';
  }

  final text = error.toString().replaceFirst('Exception: ', '').trim();
  final lower = text.toLowerCase();
  if (lower.contains('socketexception') || lower.contains('connection') || lower.contains('network')) {
    return 'Não foi possível conectar. Verifique sua internet e tente novamente.';
  }

  return text.isEmpty ? 'Algo inesperado aconteceu. Tente novamente.' : text;
}
