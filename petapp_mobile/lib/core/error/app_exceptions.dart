/// Typed exceptions for failures the UI needs to react to differently
/// (network vs. timeout vs. session expiry vs. a plain API error), each
/// carrying a message that is already safe to show to the user directly —
/// no raw exception text should ever reach a `GameSnack`.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException()
      : super('Sem conexão com a internet. Verifique sua rede e tente novamente.');
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException()
      : super('A operação demorou demais para responder. Tente novamente.');
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Sua sessão expirou. Faça login novamente.');
}

class ApiException extends AppException {
  const ApiException(this.statusCode, super.message);

  final int statusCode;
}

/// Maps any error caught around an async operation to a message that is
/// always safe to show the user — known [AppException]s use their own
/// message, anything else (a bug, an unexpected type) falls back to a
/// generic message instead of leaking implementation details.
String friendlyErrorMessage(Object error) {
  if (error is AppException) return error.message;
  return 'Algo deu errado. Tente novamente em instantes.';
}
