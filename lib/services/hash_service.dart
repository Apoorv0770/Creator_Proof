import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class HashService {
  /// Generate SHA-256 hash from file bytes
  static String generateHash(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate SHA-256 hash from string
  static String generateHashFromString(String input) {
    final bytes = Uint8List.fromList(input.codeUnits);
    return generateHash(bytes);
  }

  /// Verify if a file matches a given hash
  static bool verifyHash(Uint8List bytes, String expectedHash) {
    final actualHash = generateHash(bytes);
    return actualHash.toLowerCase() == expectedHash.toLowerCase();
  }

  /// Format hash for display (truncated)
  static String formatHashForDisplay(String hash, {int length = 16}) {
    if (hash.length <= length * 2 + 3) return hash;
    return '${hash.substring(0, length)}...${hash.substring(hash.length - length)}';
  }

  /// Validate hash format (64 hex characters for SHA-256)
  static bool isValidHash(String hash) {
    if (hash.length != 64) return false;
    return RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(hash);
  }
}
