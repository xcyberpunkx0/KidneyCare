import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the SQLCipher key for the vault database in the platform's secure
/// storage (Android Keystore / iOS Keychain). Generated once per install.
abstract final class VaultKeyStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyName = 'vault_db_key';

  static Future<String> obtainKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final key = List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await _storage.write(key: _keyName, value: key);
    return key;
  }
}
