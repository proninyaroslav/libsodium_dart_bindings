@TestOn('js')

import 'package:test/test.dart';

import './js_test_common.dart';
import 'sodium_sumo.js.fake.dart'
// ignore: conditional_uri_does_not_exist
    if (dart.library.js) 'binaries/js/sodium_sumo.js.dart';

void main() {
  JsTestRunner(
    sodiumJsSrc: sodiumJsSrc,
    isSumoTest: true,
  ).setupTests();
}
