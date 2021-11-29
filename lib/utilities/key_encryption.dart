// https://pub.dev/packages/flutter_string_encryption
// https://github.com/sroddy/flutter_string_encryption/blob/1fa478d59842931f5959e288880c384077d52bb7/lib/flutter_string_encryption.dart#L31
// import 'package:flutter_string_encryption/flutter_string_encryption.dart' show PlatformStringCryptor;
import 'package:encrypt/encrypt.dart';

class KeyEncrypt {

  // late final _encryptedPrivateKey;
  // String _key;
  // PlatformStringCryptor _crypto;

  // Activate the AES Symmetric encrypt
  String encrypt(String privateKey, String keyRing) {
    // Gets a key from the given keyRing
    final key = Key.fromUtf8(keyRing);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final _encryptedPrivateKey = encrypter.encrypt(privateKey, iv: iv);

    return _encryptedPrivateKey.base64;
  }

  // Activate the AES Symmetric decrypt
  String decrypt(String encryptedPrivateKey, String keyRing) {
    final key = Key.fromUtf8(keyRing);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final Encrypted _encryptedPrivateKey = encrypt(encryptedPrivateKey, keyRing) as Encrypted;
    // To decrypt with keyRing
    final _decryptedPrivateKey = encrypter.decrypt(_encryptedPrivateKey, iv: iv);
    print('Decrypted Output:  $_decryptedPrivateKey');

    return _decryptedPrivateKey;
  }

}