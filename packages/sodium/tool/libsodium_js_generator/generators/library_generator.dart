import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

import '../loaders/constants_loader.dart';
import '../loaders/symbols_loader.dart';
import '../loaders/type_mappings_loader.dart';
import 'lib_sodium_js_generator.dart';
import 'struct_generator.dart';
import 'typedef_generator.dart';

@immutable
class LibraryGenerator {
  final TypeMappingsLoader _typeMappingsLoader;
  final ConstantsLoader _constantsLoader;
  final SymbolsLoader _symbolsLoader;

  const LibraryGenerator(
    this._typeMappingsLoader,
    this._constantsLoader,
    this._symbolsLoader,
  );

  Future<Library> build() async {
    final builder = LibraryBuilder()
      ..ignoreForFile.add('non_constant_identifier_names')
      ..ignoreForFile.add('public_member_api_docs')
      ..directives.add(Directive.import('dart:js_interop'));

    await _buildBody().forEach(builder.body.add);

    return builder.build();
  }

  Stream<Spec> _buildBody() async* {
    for (final (name: name, type: type) in _typeMappingsLoader.dartTypeDefs) {
      yield TypedefGenerator(name: name, type: type);
    }

    await for (final struct in _typeMappingsLoader.jsCustomStructs) {
      yield StructGenerator(struct);
    }

    final constants = await _constantsLoader.loadConstants();
    final symbols = await _symbolsLoader.loadSymbols();

    yield LibSodiumJsGenerator(
      typeMapping: _typeMappingsLoader.typeMapping,
      constants: constants,
      symbols: symbols,
    );
  }
}
