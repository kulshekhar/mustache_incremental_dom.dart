import 'package:incremental_dom_facade/incremental_dom_facade.dart';

myFunc(data) {
  elementOpen('h1', '', [], {});

  text('''projects heading''');

  elementClose('h1');

  if (data.items is List) {
    for (var _fasdWQresfweb = 0, _fasdWQresfweb_l = data.items.length;
        _fasdWQresfweb < _fasdWQresfweb_l;
        _fasdWQresfweb++) {
      final a15331ecc92ce04f0d48c2988ca29c2de858 = data.items[_fasdWQresfweb];

      text('''Items: ${a15331ecc92ce04f0d48c2988ca29c2de858}
        ${a15331ecc92ce04f0d48c2988ca29c2de858.itemName}''');
      if (a15331ecc92ce04f0d48c2988ca29c2de858.cities is List) {
        for (var _fasdWQresfwec = 0,
                _fasdWQresfwec_l =
                    a15331ecc92ce04f0d48c2988ca29c2de858.cities.length;
            _fasdWQresfwec < _fasdWQresfwec_l;
            _fasdWQresfwec++) {
          final ae917878c6457b4fffaaea496f6e56eddfb1 =
              a15331ecc92ce04f0d48c2988ca29c2de858.cities[_fasdWQresfwec];

          text('''${ae917878c6457b4fffaaea496f6e56eddfb1.cityName}''');
        }
      } else if (a15331ecc92ce04f0d48c2988ca29c2de858.cities != null) {
        text('''${a15331ecc92ce04f0d48c2988ca29c2de858.cities.cityName}''');
      }
    }
  } else if (data.items != null) {
    text('''Items: ${data.items}
        ${data.items.itemName}''');
    if (data.items.cities is List) {
      for (var _fasdWQresfwed = 0, _fasdWQresfwed_l = data.items.cities.length;
          _fasdWQresfwed < _fasdWQresfwed_l;
          _fasdWQresfwed++) {
        final acea6dbc4145cb426fbb857c0522de67c879 =
            data.items.cities[_fasdWQresfwed];

        text('''${acea6dbc4145cb426fbb857c0522de67c879.cityName}''');
      }
    } else if (data.items.cities != null) {
      text('''${data.items.cities.cityName}''');
    }
  }

  elementOpen('div', '', [], {
    'class': '''row''',
  });

  if (data.projects is List) {
    for (var _fasdWQresfweb = 0, _fasdWQresfweb_l = data.projects.length;
        _fasdWQresfweb < _fasdWQresfweb_l;
        _fasdWQresfweb++) {
      final aeab71dd2d33f34bfd8905870c43a0ec42da =
          data.projects[_fasdWQresfweb];

      elementOpen('a', '', [], {
        'href': '''${aeab71dd2d33f34bfd8905870c43a0ec42da.url}''',
        'class': '''block''',
      });

      elementOpen('h2', '', [], {});

      text('''${aeab71dd2d33f34bfd8905870c43a0ec42da.name}''');

      elementClose('h2');

      elementOpen('p', '', [], {});

      text('''${aeab71dd2d33f34bfd8905870c43a0ec42da.description}''');

      elementClose('p');

      elementClose('a');
    }
  } else if (data.projects != null) {
    elementOpen('a', '', [], {
      'href': '''${data.projects.url}''',
      'class': '''block''',
    });

    elementOpen('h2', '', [], {});

    text('''${data.projects.name}''');

    elementClose('h2');

    elementOpen('p', '', [], {});

    text('''${data.projects.description}''');

    elementClose('p');

    elementClose('a');
  }

  elementClose('div');

  elementOpen('h3', '', [], {});

  text('''Today.''');

  elementClose('h3');

  if (data.repo == null) {
    text('''No repos :(''');
  }

  elementOpen('custom-component', '', [], {
    'att1': '''33''',
  });

  text('''something''');

  elementClose('custom-component');

  elementVoid('img', 'i1', [
    'data-custom',
    '''cc''',
  ], {
    'id': '''i1''',
    'src': '''http://example1.com''',
  });

  elementVoid('img', '', [], {
    'src': '''http://example2.com''',
  });

  elementOpen('div', '', [], {});

  text('''Hello ${data.firstname}''');

  elementClose('div');

  elementOpen('div', '', [], {});

  text('''Hello ${data.somevar}''');

  elementClose('div');

  if (data.things is List) {
    for (var _fasdWQresfweb = 0, _fasdWQresfweb_l = data.things.length;
        _fasdWQresfweb < _fasdWQresfweb_l;
        _fasdWQresfweb++) {
      final a4de65f845a6ba4e043b373a18e040398250 = data.things[_fasdWQresfweb];

      text('''${a4de65f845a6ba4e043b373a18e040398250.id}''');
    }
  } else if (data.things != null) {
    text('''${data.things.id}''');
  }

  text('''${data.unescapedVariable}''');

  elementOpen('div', '', [], {
    'class': '''back''',
  });

  elementOpen('a', '', [], {
    'href': '''/''',
  });

  text('''↩''');

  elementClose('a');

  elementClose('div');
}
