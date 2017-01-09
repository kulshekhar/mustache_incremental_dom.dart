// GENERATED CODE - DO NOT MODIFY BY HAND

part of hello_world;

// **************************************************************************
// Generator: IdomFunctionGenerator
// Target: class HelloWorld
// **************************************************************************

render(data) {
  text('''Hello ${data.name}!!
''');

  elementOpen('h1', '', [
    'onclick',
    allowInterop(data.onH1Click),
  ], {});

  text('''Hello ${data.name}''');

  elementClose('h1');

  elementOpen('p', '', [], {});

  text('''I see that you're
  ''');

  elementOpen('span', '', [
    'onclick',
    allowInterop(data.onAgeClick),
  ], {});

  text('''${data.age}''');

  elementClose('span');

  text(''' years old and live at ''');

  elementOpen('span', '', [], {});

  text('''${data.address}''');

  elementClose('span');

  elementClose('p');

  elementOpen('h3', '', [], {});

  text('''Enter your name''');

  elementClose('h3');

  elementVoid('input', '', [
    'oninput',
    allowInterop(data.onInput),
  ], {
    'type': '''text''',
    'value': '''${data.name}''',
  });

  elementOpen('button', '', [
    'onclick',
    allowInterop(data.reset),
  ], {});

  text('''Reset Name''');

  elementClose('button');

  elementOpen('div', '', [], {});

  text('''
  hello partial!! ${data.name}
''');

  elementClose('div');
}
