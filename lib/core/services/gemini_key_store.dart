import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the caregiver's own Gemini API key in the platform's secure
/// storage (Android Keystore / iOS Keychain), so public builds can ship
/// without any key baked in — the caregiver pastes theirs in Settings.
abstract final class GeminiKeyStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyName = 'gemini_api_key';

  /// Returns the stored key, or an empty string when none is set.
  static Future<String> read() async =>
      await _storage.read(key: _keyName) ?? '';

  static Future<void> write(String value) =>
      _storage.write(key: _keyName, value: value);

  static Future<void> delete() => _storage.delete(key: _keyName);
}

/// Loaded once at startup and overridden into the container, so key
/// reads are synchronous everywhere.
final initialGeminiKeyProvider = Provider<String>((ref) {
  throw UnimplementedError('Overridden in main()');
});

/// The key pasted in Settings; empty string when unset. Takes precedence
/// over any bundled `.env` / `--dart-define` key.
class GeminiKeyController extends Notifier<String> {
  @override
  String build() => ref.read(initialGeminiKeyProvider);

  /// Persists [value] (trimmed); an empty value removes the stored key.
  Future<void> set(String value) async {
    final trimmed = value.trim();
    state = trimmed;
    if (trimmed.isEmpty) {
      await GeminiKeyStore.delete();
    } else {
      await GeminiKeyStore.write(trimmed);
    }
  }
}

final geminiKeyProvider =
    NotifierProvider<GeminiKeyController, String>(GeminiKeyController.new);
