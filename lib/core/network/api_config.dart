/// Configuration for the Gemini API.
///
/// The caregiver's own key, pasted in Settings and kept in secure
/// storage, is the primary source (see `GeminiKeyStore`). For developer
/// builds, `--dart-define=GEMINI_API_KEY=...` provides a fallback. No
/// key is ever bundled into the app package.
abstract final class ApiConfig {
  static const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static const geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// The stable alias that always points at the newest flash model, so
  /// the app never breaks when a pinned version is retired.
  static const geminiModel = 'gemini-flash-latest';

  static String get generateContentPath =>
      '/models/$geminiModel:generateContent';
}
