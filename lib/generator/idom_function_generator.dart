import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'dart:async';
import 'dart:io';
import 'package:mustache_incremental_dom/generator/generator.dart';
import 'package:path/path.dart' as p;
import 'package:mustache_incremental_dom/generator/template.dart';
import 'package:source_gen/source_gen.dart';

class IdomFunctionGenerator extends GeneratorForAnnotation<Template> {
  const IdomFunctionGenerator();

  @override
  Future<String> generateForAnnotatedElement(
      Element element, Template annotation, BuildStep buildStep) async {
    //
    final templateStr = await _getTemplateStr(annotation, buildStep);

    final g = new IDOMGenerator(trimText: false, dataType: IDOMDataType.Object);
    return g.generate(templateStr, annotation.functionName,
        directory: p.dirname(buildStep.input.id.path));
  }

  Future<String> _getTemplateStr(
      Template annotation, BuildStep buildStep) async {
    if (annotation.template.isEmpty && annotation.templateUrl.isEmpty) {
      throw 'Either template or templateUrl must be supplied';
    }

    if (annotation.templateUrl.isNotEmpty) {
      if (p.isAbsolute(annotation.templateUrl)) {
        throw 'must be relative path to the template file';
      }

      final sourcePathDir = p.dirname(buildStep.input.id.path);
      final filePath = p.join(sourcePathDir, annotation.templateUrl);

      if (!(await FileSystemEntity.isFile(filePath))) {
        throw 'template could not be found';
      }

      var fileId = new AssetId(buildStep.input.id.package,
          p.join(sourcePathDir, annotation.templateUrl));

      return await buildStep.readAsString(fileId);
    }

    return annotation.template;
  }
}
