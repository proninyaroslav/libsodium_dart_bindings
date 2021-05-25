import 'dart:typed_data';

import '../../../../api/sign.dart';
import '../../../bindings/js_error.dart';
import '../../../bindings/sodium.js.dart';
import 'sign_consumer_js_mixin.dart';

class VerificationConsumerJS
    with SignConsumerJSMixin<bool>
    implements VerificationConsumer {
  @override
  final LibSodiumJS sodium;

  final Uint8List signature;
  final Uint8List publicKey;

  VerificationConsumerJS({
    required this.sodium,
    required this.signature,
    required this.publicKey,
  }) {
    initState();
  }

  @override
  Future<bool> get signatureValid => result;

  @override
  bool finalize(num state) => JsError.wrap(
        () => sodium.crypto_sign_final_verify(
          state,
          signature,
          publicKey,
        ),
      );
}