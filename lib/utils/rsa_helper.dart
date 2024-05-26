import 'package:fast_rsa/fast_rsa.dart';

class RsaKeyHelper {
  // Generates a new RSA key pair
  static Future<Map<String, String>> generateRSAKeyPair() async {
    var keyPair = await RSA.generate(2048);
    return {
      'privateKey': keyPair.privateKey,
      'publicKey': keyPair.publicKey,
    };
  }

  // Encrypts a message using a public key
  static Future<String> encryptWithPublicKey(String message, String publicKey) async {
    try {
      return await RSA.encryptPKCS1v15(message, publicKey);
    } catch (e) {
      print('Encryption error: $e');
      rethrow;
    }
  }

  // Decrypts a message using a private key
  static Future<String> decryptWithPrivateKey(String encryptedMessage, String privateKey) async {
    try {
      print('Starting decryption...');
      print('Encrypted message: $encryptedMessage');
      print('Private key: $privateKey');
      var decryptedMessage = await RSA.decryptPKCS1v15(encryptedMessage, privateKey);
      print('Decrypted message: $decryptedMessage');
      return decryptedMessage;
    } catch (e) {
      print('Decryption error: $e');
      rethrow;
    }
  }
}
