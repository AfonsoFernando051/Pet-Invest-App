/// Shared input validation rules — kept in one place so every form applies
/// the same definition of "valid email" / "valid password" instead of each
/// screen inventing (or forgetting) its own.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String email) => _emailPattern.hasMatch(email.trim());

  static const int nameMaxLength = 40;
}

/// Production password policy: at least 8 characters, one uppercase, one
/// lowercase and one digit. Special characters are encouraged but not
/// required, matching common UX guidance (requiring them tends to push
/// users toward predictable substitutions like "Passw0rd!").
class PasswordRule {
  const PasswordRule(this.label, this.test);

  final String label;
  final bool Function(String password) test;

  bool isMet(String password) => test(password);
}

final List<PasswordRule> passwordRules = [
  PasswordRule('Mínimo de 8 caracteres', (p) => p.length >= 8),
  PasswordRule('Uma letra maiúscula', (p) => p.contains(RegExp(r'[A-Z]'))),
  PasswordRule('Uma letra minúscula', (p) => p.contains(RegExp(r'[a-z]'))),
  PasswordRule('Um número', (p) => p.contains(RegExp(r'[0-9]'))),
];

bool isPasswordValid(String password) => passwordRules.every((rule) => rule.isMet(password));
