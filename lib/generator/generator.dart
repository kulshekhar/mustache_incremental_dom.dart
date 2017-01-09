import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:dart_style/dart_style.dart' as style;
import 'package:path/path.dart';

const String _M_ALL_START = '__##_';
const String _M_ALL_END = '_##__';
const String _M_VARNAME_START = '$_M_ALL_START\VAR';
const String _M_VARNAME_END = _M_ALL_END;
const String _M_UNVARNAME_START = '$_M_ALL_START\UNVAR';
const String _M_UNVARNAME_END = _M_ALL_END;
const String _M_NEGATED_START = '$_M_ALL_START\NEGATED';
const String _M_NEGATED_END = _M_ALL_END;
const String _M_BLOCKNAME_START = '$_M_ALL_START\BLOCK';
const String _M_BLOCKNAME_END = _M_ALL_END;
const String _M_ELSE_START = '$_M_ALL_START\ELSE';
const String _M_BLOCK_ENDING = '$_M_ALL_START\BLKEND$_M_ALL_END';

const String _ITERATOR_PRE = '_fasdWQresfwe';
const String _regexNameMatcher = r'([a-zA-Z0-9_\-\$\.\[\]"]+)';
final RegExp _regexVar =
    new RegExp(_M_VARNAME_START + _regexNameMatcher + _M_VARNAME_END);
final RegExp _regexUnvar =
    new RegExp(_M_UNVARNAME_START + _regexNameMatcher + _M_UNVARNAME_END);
final RegExp _regexBlock =
    new RegExp(_M_BLOCKNAME_START + _regexNameMatcher + _M_BLOCKNAME_END);
final RegExp _regexNegated =
    new RegExp(_M_NEGATED_START + _regexNameMatcher + _M_NEGATED_END);

final RegExp _regexBlockOrEnd = new RegExp(
  '$_M_ALL_START(BLOCK|NEGATED|ELSE)' +
      _regexNameMatcher +
      '$_M_ALL_END|$_M_BLOCK_ENDING',
);

class IDOMGenerator {
  bool _trimText;
  IDOMDataType _dataType;
  String _directory;

  IDOMGenerator({bool trimText = true, IDOMDataType dataType}) {
    _trimText = trimText ?? true;
    _dataType = dataType ?? IDOMDataType.Object;
  }

  String generate(String template, String functionName,
      {String directory, String templateUrl, bool templateOnly: false}) {
    _directory = directory ?? '.';
    if (templateUrl != null) {
      template = _getTemplateContent(templateUrl);
    }

    final parsedMustache = _parseMustache(template);
    final intermediateTemplate = _processParsedMustache(parsedMustache, 'data');

    if (templateOnly) return intermediateTemplate;

    final doc = htmlParser.parse(intermediateTemplate);
    final functionBody = _getFunctionFromBody(doc.body);

    final fn = '''$functionName(data) {
      $functionBody
    }
    ''';

    final formattedFn = new style.DartFormatter().format(fn);

    return formattedFn;
  }

  String _getTemplateContent(String filename) {
    final sourcePathDir = dirname(_directory);
    final filePath = join(sourcePathDir, filename);

    if (!(FileSystemEntity.isFileSync(filePath))) {
      throw 'template could not be found: $filePath';
    }

    return new File(filePath).readAsStringSync();
  }

  String _processParsedMustache(List<List> tokenList, String parentVariable) {
    var str = '';

    tokenList?.forEach((List innerList) {
      final token = innerList[0];
      final value = innerList[1];
      final varAccessor = _createAccessor(parentVariable, value);

      switch (token) {
        case '#':
          // block or loop
          final childVarName = _getRandomIdentifier(); //length = 36
          str += _processMustacheBlock(varAccessor, childVarName);

          // process children
          str += _processParsedMustache(innerList[4], childVarName);

          str += '$_M_BLOCK_ENDING\n';
          // add else block
          str += _processMustacheElseBlock(varAccessor, childVarName);
          str += _processParsedMustache(innerList[4], varAccessor);
          str += '$_M_BLOCK_ENDING\n';
          break;
        case '&':
          // unescaped variable
          str += _processMustacheUnescapedVariable(varAccessor);
          break;
        case '^':
          // negated block
          str += _processMustacheNegatedBlock(varAccessor);
          str += _processParsedMustache(innerList[4], varAccessor);
          str += '$_M_BLOCK_ENDING\n';
          break;
        case '!':
          // comment
          str += _processMustacheComment(value);
          break;
        case 'name':
          // variable
          str += _processMustacheVariable(varAccessor);
          break;
        case 'text':
          // text
          str += _processMustacheText(value);
          break;
        case '>':
          // partial
          str += _getPartialContent(value);
          break;
        default:
          throw new Exception('Unexpected token: $token');
      }
    });

    return str;
  }

  String _getPartialContent(String templateName) {
    final g = new IDOMGenerator(trimText: _trimText, dataType: _dataType);
    return g.generate('', '_innerFunction',
        directory: _directory,
        templateUrl: _getTemplateNameFromFile(templateName),
        templateOnly: true);
  }

  String _getTemplateNameFromFile(String templateName) {
    final sourcePathDir = dirname(_directory);
    final extensions = ['html', 'mustache'];
    for (var i = 0; i < extensions.length; i++) {
      final tmpName = '$templateName.${extensions[i]}';
      final filePath = join(sourcePathDir, tmpName);
      if (FileSystemEntity.isFileSync(filePath)) return tmpName;
    }

    throw 'template could not be found: $templateName';
  }

  String _processMustacheBlock(String varName, String childVarName) {
    return '$_M_BLOCKNAME_START$varName\__$childVarName$_M_BLOCKNAME_END\n';
  }

  String _processMustacheElseBlock(String varName, String childVarName) {
    return '$_M_ELSE_START$varName\__$childVarName$_M_ALL_END\n';
  }

  String _processMustacheUnescapedVariable(String varAccessor) {
    return '$_M_UNVARNAME_START$varAccessor$_M_UNVARNAME_END';
  }

  String _processMustacheVariable(String varAccessor) {
    if (varAccessor.endsWith('..')) {
      varAccessor = varAccessor.substring(0, varAccessor.length - 2);
    } else if (varAccessor.endsWith('["."]')) {
      varAccessor = varAccessor.substring(0, varAccessor.length - 5);
    }
    return '$_M_VARNAME_START$varAccessor$_M_VARNAME_END';
  }

  String _processMustacheText(String text) {
    return '$text';
  }

  String _processMustacheComment(String comment) {
    // return '<!-- $comment -->';
    return '';
  }

  String _processMustacheNegatedBlock(String varAccessor) {
    return '$_M_NEGATED_START$varAccessor$_M_NEGATED_END\n';
  }

  List _parseMustache(String text) {
    final result = Process.runSync('node', ['m.js', text]);

    if (result.exitCode != 0) {
      print(result.stderr);
      exit(result.exitCode);
    }

    final mustacheTokenString =
        result.stdout.toString().trim().replaceAll("'''", "\\'\\'\\'");

    final List mustacheTokens = JSON.decode(mustacheTokenString);

    return mustacheTokens;
  }

  String _createAccessor(String parentName, String childName) {
    return _dataType == IDOMDataType.Map
        ? '$parentName["$childName"]'
        : '$parentName.$childName';
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
    final txt = _trimText ? t.text.trim() : t.text;
    final String varProcessedText = [_placeholderToVar, _placeholderToUnvar]
        .fold(
            txt,
            (String prev, Function curr) =>
                _trimText ? curr(prev).trim() : curr(prev));

    var varI = 'a';

    final blockProcessedText = varProcessedText.splitMapJoin(
      _regexBlockOrEnd,
      onNonMatch: _textBlock,
      onMatch: (Match m) {
        if (m.group(0).startsWith(_M_BLOCK_ENDING)) {
          return '''
            }
          ''';
        } else if (m.group(0).startsWith(_M_BLOCKNAME_START)) {
          final String completeIdentifier = m.group(2);
          final innerVarName =
              completeIdentifier.substring(completeIdentifier.length - 36);
          final outerVarName =
              completeIdentifier.substring(0, completeIdentifier.length - 38);

          varI = new String.fromCharCode(varI.codeUnitAt(0) + 1);
          if (varI == 'z') {
            varI = 'b';
          }
          final iterator = '$_ITERATOR_PRE$varI';

          return '''
          if ($outerVarName is List) {
              for (var $iterator = 0, $iterator\_l = $outerVarName.length; $iterator < $iterator\_l; $iterator++) {
                final $innerVarName = $outerVarName[$iterator];
          ''';
        } else if (m.group(0).startsWith(_M_ELSE_START)) {
          final String completeIdentifier = m.group(2);
          final innerVarName =
              completeIdentifier.substring(completeIdentifier.length - 36);
          final outerVarName =
              completeIdentifier.substring(0, completeIdentifier.length - 38);

          return '''} else if ($outerVarName != null) {
          ''';
        } else if (m.group(0).startsWith(_M_NEGATED_START)) {
          final String completeIdentifier = m.group(2);

          return '''
            if ($completeIdentifier == null) {              
          ''';
        }

        return m.group(0);
      },
    );

    final finalTxt = blockProcessedText;

    return finalTxt;
  }

  String _textBlock(String s) => s.trim().isNotEmpty
      ? '''

  text(\'\'\'${_trimText ? s.trim() : s}\'\'\');
  '''
      : '';

  Map _getProperties(Map m) {
    var staticPropertyValuePairs = '';
    var propertyValuePairs = '';

    m.forEach((String k, v) {
      if (k.toLowerCase().startsWith('s:')) {
        final newK = k.substring(2);
        staticPropertyValuePairs += "'$newK', ";
        if (v is String) {
          staticPropertyValuePairs += newK.startsWith('on')
              ? _getEventHandlerProperty(_placeholderToVar(v))
              : "'''${_placeholderToVar(v)}''',";
        } else {
          staticPropertyValuePairs += "$v,";
        }
      } else {
        propertyValuePairs += "'$k': ";
        if (v is String) {
          propertyValuePairs += k.startsWith('on')
              ? _getEventHandlerProperty(_placeholderToVar(v))
              : "'''${_placeholderToVar(v)}''',";
        } else {
          propertyValuePairs += "$v,";
        }
      }
    });

    return {'s': staticPropertyValuePairs, 'p': propertyValuePairs};
  }

  String _getEventHandlerProperty(String s) {
    s = s.replaceAll('(', '').replaceAll(')', '');
    return _dataType == IDOMDataType.Object
        ? 'allowInterop(data.$s),'
        : "allowInterop(data['$s']),";
  }

  String _placeholderToVar(String s) {
    return s.replaceAllMapped(_regexVar, (m) {
      return '\${${m.group(1)}}';
    });
  }

  String _placeholderToUnvar(String s) {
    return s.replaceAllMapped(_regexUnvar, (m) {
      return '\${${m.group(1)}}';
    });
  }

  String _getRandomIdentifier() {
    final Random random = new Random.secure();

    final String hexDigits = "0123456789abcdef";
    final List<String> uuid = new List<String>(36);

    for (int i = 0; i < 36; i++) {
      final int hexPos = random.nextInt(16);
      uuid[i] = (hexDigits.substring(hexPos, hexPos + 1));
    }

    int pos = (int.parse(uuid[19], radix: 16) & 0x3) | 0x8;

    uuid[14] = "4";
    uuid[19] = hexDigits.substring(pos, pos + 1);
    uuid[0] = 'a';

    // uuid[8] = uuid[13] = uuid[18] = uuid[23] = "";

    return (new StringBuffer()..writeAll(uuid)).toString();
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

// class _EventHandler {
//   String name;
//   List<String> params;
//   String paramsStr;
//   IDOMDataType _dataType;

//   _EventHandler(String handlerText, [this._dataType = IDOMDataType.Object]) {
//     _parseText(handlerText ?? '');
//   }

//   getFormatted() {
//     if (_dataType == IDOMDataType.Object) {
//       return 'data.$name($paramsStr)';
//     }
//     return "data['$name']($paramsStr)";
//   }

//   _parseText(String s) {
//     if (s.contains('(')) {
//       // params are given
//       final parts = s.trim().split('(');
//       name = parts[0];
//       params = parts[1] //
//           .substring(0, parts[1].length - 1) //
//           .split(',') //
//           .map((String p) {
//         //
//         return _dataType == IDOMDataType.Object
//             ? 'data.${p.trim()}'
//             : "data['${p.trim()}']";
//       });
//     } else {
//       // params aren't given. Just supply the event
//       name = s.trim();
//       params = ['\$event'];
//     }
//     paramsStr = params.length > 0 ? params.join(', ') : '';
//   }
// }
