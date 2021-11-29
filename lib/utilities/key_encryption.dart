// https://stackoverflow.com/questions/57109308/how-to-encrypt-a-string-and-decrypt-this-encrypted-string-in-other-device-in-flu
import 'package:encrypt/encrypt.dart';

class KeyEncrypt {

  // Activate the AES Symmetric encrypt
  Encrypted getEncryption(String privateKey, String passphrase) {
    // Gets a key from the given keyRing
    final key = Key.fromUtf8(passphrase);
    final iv = IV.fromLength(8);
    final encrypter = Encrypter(AES(key));
    final _encryptedPrivateKey = encrypter.encrypt(privateKey, iv: iv);

    return _encryptedPrivateKey;
  }

  // Activate the AES Symmetric decrypt
  String getDecryption(Encrypted encryptedPrivateKey, String passphrase) {
    final key = Key.fromUtf8(passphrase);
    final iv = IV.fromLength(8);
    final encrypter = Encrypter(AES(key));
    // To decrypt with keyRing
    final _decryptedPrivateKey = encrypter.decrypt(encryptedPrivateKey, iv: iv);

    return _decryptedPrivateKey;
  }

}