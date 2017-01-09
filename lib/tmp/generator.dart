import 'dart:io';
import 'dart:convert';

import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:dart_style/dart_style.dart' as style;

const _tokenBegin = '__#';
const _tokenEnd = '#__';
const _tokenForStart = '${_tokenBegin}_FOR_START_%VARIABLE%_${_tokenEnd}';
const _tokenForEnd = '${_tokenBegin}_FOR_END_${_tokenEnd}';
const _tokenVariable = '${_tokenBegin}_VAR_%VARIABLE%_${_tokenEnd}';

class IDOMGenerator {
  bool _trimText;
  IDOMDataType _dataType;
  String _template = '';

  IDOMGenerator({bool trimText = true, IDOMDataType dataType}) {
    _trimText = trimText ?? true;
    _dataType = dataType ?? IDOMDataType.Object;
  }

  String generate(String template, String functionName) {
    _template = template;
    final doc = htmlParser.parse(template);
    final functionBody = _getFunctionFromBody(doc.body);

    print(Process.runSync('node', ['m.js', _template]).stdout);

    return new style.DartFormatter().format('''$functionName(data) {
      $functionBody
    }
    ''');
  }

  String _processMustache(String text) {
    final _pre = _dataType == IDOMDataType.Object ? '.' : '["';
    final _post = _dataType == IDOMDataType.Object ? '' : '"]';

    final result = Process.runSync('node', ['m.js', text]);

    if (result.exitCode != 0) {
      print(result.stderr);
      exit(result.exitCode);
    }

    final str = _parseMustacheTokens(result.stdout.trim());

    return str.replaceAll("'''", "\\'\\'\\'");
  }

  String _parseMustacheTokens(String json) {
    if (json.isEmpty) return '';

    final List decoded = JSON.decode(json);
    print(decoded);

    return json;
  }

  String _getFunctionFromBody(dom.Element e) {
    var patch = '';

    e.nodes.forEach((n) {
      patch += _createPatcher(n);
    });

    return patch;
  }

  String _createPatcher(dom.Element e, [String patcherCode = '']) {
    if (e is dom.Text) {
      if (e.text.trim().isNotEmpty) {
        patcherCode += _getTextPatch(e as dom.Text);
      }
    } else {
      if (_isEmptyElement(e.localName)) {
        patcherCode += _getStandalonePatch(e);
      } else {
        var innerCode = '';
        if (e.hasChildNodes()) {
          e.nodes.forEach((e1) {
            innerCode += _createPatcher(e1, patcherCode);
          });
        }

        patcherCode += _getFullPatch(e, innerCode);
      }
    }

    return patcherCode;
  }

  String _getStandalonePatch(dom.Element e) {
    final tagName = e.localName;
    final id = e.id;

    final properties = _getProperties(e.attributes);

    final staticPropertyValuePairs = '[${properties["s"]}]';
    final propertyValuePairs = '{${properties["p"]}}';

    return '''

  elementVoid('$tagName', '$id', $staticPropertyValuePairs, $propertyValuePairs);
  
  ''';
  }

  String _getFullPatch(dom.Element e, [String innerCode = '']) {
    final tagName = e.localName;
    final id = e.id;

    final properties = _getProperties(e.attributes);

    final staticPropertyValuePairs = '[${properties["s"]}]';
    final propertyValuePairs = '{${properties["p"]}}';

    return '''

    elementOpen('$tagName', '$id', $staticPropertyValuePairs, $propertyValuePairs);
  
    $innerCode

    elementClose('$tagName');
    
    ''';
  }

  String _getTextPatch(dom.Text t) {
    final txt =
        _trimText ? _processMustache(t.text.trim()) : _processMustache(t.text);

    return '''

  text(\'\'\'$txt\'\'\');''';
  }

  Map _getProperties(Map m) {
    var staticPropertyValuePairs = '';
    var propertyValuePairs = '';

    m.forEach((String k, v) {
      if (k.toLowerCase().startsWith('s:')) {
        final newK = k.substring(2);
        staticPropertyValuePairs += "'$newK', ";
        if (v is String) {
          staticPropertyValuePairs += "'''${_processMustache(v)}''',";
        } else {
          staticPropertyValuePairs += "$v,";
        }
      } else {
        propertyValuePairs += "'$k': ";
        if (v is String) {
          propertyValuePairs += "'''${_processMustache(v)}''',";
        } else {
          propertyValuePairs += "$v,";
        }
      }
    });

    return {'s': staticPropertyValuePairs, 'p': propertyValuePairs};
  }

  bool _isEmptyElement(String tagName) => _emptyElements.contains(tagName);

  final List _emptyElements = const [
    'link',
    'track',
    'param',
    'area',
    'command',
    'col',
    'base',
    'meta',
    'hr',
    'source',
    'img',
    'keygen',
    'br',
    'wbr',
    'colgroup',
    'input',
  ];
}

enum IDOMDataType {
  Map,
  Object,
}
