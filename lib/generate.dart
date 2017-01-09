import 'package:mustache_incremental_dom/generator/generator.dart';

generate(String template) {
  final g = new IDOMGenerator();
  g.generate(template, 'myFunc');
}
