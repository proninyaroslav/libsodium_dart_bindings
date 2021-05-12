import 'auth.dart';
import 'box.dart';
import 'pwhash.dart';
import 'secret_box.dart';
import 'secret_stream.dart';
import 'sign.dart';

/// A meta class that provides access to all libsodium crypto APIs.
abstract class Crypto {
  const Crypto._(); // coverage:ignore-line

  /// An instance of [SecretBox].
  ///
  /// This provides all APIs that start with `crypto_secretbox`.
  SecretBox get secretBox;

  /// An instance of [SecretStream].
  ///
  /// This provides all APIs that start with `crypto_secretstream`.
  SecretStream get secretStream;

  /// An instance of [Auth].
  ///
  /// This provides all APIs that start with `crypto_auth`.
  Auth get auth;

  /// An instance of [Box].
  ///
  /// This provides all APIs that start with `crypto_box`.
  Box get box;

  /// An instance of [Sign].
  ///
  /// This provides all APIs that start with `crypto_sign`.
  Sign get sign;

  /// An instance of [Pwhash].
  ///
  /// This provides all APIs that start with `crypto_pwhash`.
  Pwhash get pwhash;
}
