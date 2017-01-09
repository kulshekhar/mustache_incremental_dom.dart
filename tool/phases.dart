import 'package:build_runner/build_runner.dart';

import 'package:mustache_playground/generator/idom_function_generator.dart';

import 'package:source_gen/source_gen.dart';

final PhaseGroup phases = new PhaseGroup.singleAction(
    new GeneratorBuilder(const [
      const IdomFunctionGenerator(),
    ]),
    new InputSet('mustache_playground', const [
      'lib/playground/*.dart',
      'lib/playground/*.html',
    ]));
