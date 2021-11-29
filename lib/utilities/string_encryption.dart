// https://pub.dev/packages/flutter_string_encryption
// https://github.com/sroddy/flutter_string_encryption/blob/1fa478d59842931f5959e288880c384077d52bb7/lib/flutter_string_encryption.dart#L31
import 'package:flutter_string_encryption/flutter_string_encryption.dart' show PlatformStringCryptor;

class StringCrypt {

  // final cryptor = PlatformStringCryptor();
  // final String key = await cryptor.generateRandomKey();
  // final password = "user_provided_password";
  // final String salt = await cryptor.generateSalt();
  // final String key = await cryptor.generateKeyFromPassword(password, salt);
  // final String encrypted = await cryptor.encrypt("A string to encrypt.", key);
  // try {
  // final String decrypted = await cryptor.decrypt(encrypted, key);
  // print(decrypted); // - A string to encrypt.
  // } on MacMismatchException {
  // // unable to decrypt (wrong key or forged data)
  // }

  StringCrypt({
    String key,
    String password,
    String salt,
  }) {
    _crypto = PlatformStringCryptor();
    if (key != null && key.trim().isNotEmpty) {
      _key = key;
    } else {
      _keyFromPassword(password, salt).then((String key) {
        _key = key;
      });
    }
  }
  String _key;
  PlatformStringCryptor _crypto;

  Future<String> en(String data, [String key]) => encrypt(data, key);

  Future<String> encrypt(String data, [String key]) async {
    if (key != null) {
      key = key.trim();
      if (key.isEmpty) key = null;
    }
    String encrypt;
    try {
      encrypt = await _crypto.encrypt(data, key ??= _key);
    } catch (ex) {
      encrypt = "";
      getError(ex);
    }
    return encrypt;
  }

  Future<String> de(String data, [String key]) => decrypt(data, key);

  Future<String> decrypt(String data, [String key]) async {
    if (key != null) {
      key = key.trim();
      if (key.isEmpty) key = null;
    }
    String decrypt;
    try {
      decrypt = await _crypto.decrypt(data, key ??= _key);
    } catch (ex) {
      decrypt = "";
      getError(ex);
    }
    return decrypt;
  }

  // You will need a key to decrypt things and so on.
  Future<String> generateRandomKey() => _crypto.generateRandomKey();

  // Generates a salt to use with [generateKeyFromPassword]
  Future<String> generateSalt() => _crypto.generateSalt();

  // Gets a key from the given [password] and [salt].
  Future<String> generateKeyFromPassword(String password, String salt) =>
      _crypto.generateKeyFromPassword(password, salt);

  Future<String> _keyFromPassword(String password, String salt) async {
    if (password == null || password.trim().isEmpty) return "";
    String _salt;
    if (salt == null || salt.trim().isEmpty) {
      _salt = await generateSalt();
    } else {
      _salt = salt.trim();
    }
    return await generateKeyFromPassword(password, _salt);
  }

  bool get hasError => _error != null;

  bool get inError => _error != null;
  Object _error;

  Exception getError([Object error]) {
    // Return the stored exception
    Exception ex = _error;
    // Empty the stored exception
    if (error == null) {
      _error = null;
    } else {
      if (error is! Exception) error = Exception(error.toString());
      _error = error;
    }
    // Return the exception just past if any.
    if (ex == null) ex = error;
    return ex;
  }

}