import 'package:encrypt/encrypt.dart';

class KeyEncrypt {

  // Activate the AES Symmetric encrypt with keyring input
  Encrypted getEncryptionKeyRing(String privateKey, String passphrase) {
    // Gets a key from the given keyRing
    final key = Key.fromUtf8(passphrase);
    final iv = IV.fromLength(8);
    final encrypter = Encrypter(AES(key));
    final _encryptedPrivateKey = encrypter.encrypt(privateKey, iv: iv);

    return _encryptedPrivateKey;
  }

  // Activate the AES Symmetric decrypt with keyring input
  String getDecryptionKeyRing(Encrypted encryptedPrivateKey, String passphrase) {
    final key = Key.fromUtf8(passphrase);
    final iv = IV.fromLength(8);
    final encrypter = Encrypter(AES(key));
    // To decrypt with keyRing
    final _decryptedPrivateKey = encrypter.decrypt(encryptedPrivateKey, iv: iv);

    return _decryptedPrivateKey;
  }

  // Activate the AES Symmetric encrypt without passphrase input
  Encrypted getEncryption(String privateKey) {
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final _encryptedPrivateKey = encrypter.encrypt(privateKey, iv: iv);

    return _encryptedPrivateKey;
  }

  // Activate the AES Symmetric decrypt without passphrase input
  String getDecryption(Encrypted encryptedPrivateKey) {
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key));
    final _decryptedPrivateKey = encrypter.decrypt(encryptedPrivateKey, iv: iv);

    return _decryptedPrivateKey;
  }

}