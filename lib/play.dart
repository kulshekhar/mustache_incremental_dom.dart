import 'dart:html';
import 'package:mustache/mustache.dart';
import 'package:incremental_dom_facade/incremental_dom_facade.dart';

Map data = {
  'names': [
    {'firstname': 'Greg', 'lastname': 'Lowe'},
    {'firstname': 'Bob', 'lastname': 'Johnson'}
  ]
};

var _idom = false;

void render(Element parent, String page, {bool useIdom = false}) {
  switch (page) {
    case 'page1':
      data = {
        'names': [
          {'firstname': 'Alpha', 'lastname': 'Phi'},
          {'firstname': 'Beta', 'lastname': 'Chi'}
        ]
      };
      renderPage(parent, template1, useIdom: useIdom);
      break;
    case 'page2':
      data = {
        'names': [
          {'firstname': 'Gamma', 'lastname': 'Psi'},
          {'firstname': 'Delta', 'lastname': 'Omega'}
        ]
      };
      renderPage(parent, template2, useIdom: useIdom);
      break;
  }
}

final Template template1 = new Template(
    '''
	  {{# names }}
            <div>{{ lastname }}, {{ firstname }}</div>
	  {{/ names }}

	  {{! I am a comment. }}
	''',
    name: 't1.html');

renderTemplate1(_) {
  for (final name in data['names']) {
    elementOpen('div');
    text('${name["lastname"]}, ${name["firstname"]}');
    elementClose('div');
  }
}

final Template template2 = new Template(
    '''
	  {{# names }}
            <div>{{ lastname }}, {{ firstname }}</div>
	  {{/ names }}

	  {{! I am a comment. }}
	''',
    name: 't2.html');

renderTemplate2(_) {
  for (final name in data['names']) {
    elementOpen('div');
    text('${name["lastname"]}, ${name["firstname"]}');
    elementClose('div');
  }
}

renderPage(Element parent, Template t, {bool useIdom = false}) {
  if (!useIdom) {
    parent.innerHtml = t.renderString(data);
  } else {
    switch (t.name) {
      case 't1.html':
        patch(parent, renderTemplate1);
        break;
      case 't2.html':
        patch(parent, renderTemplate2);
        break;
    }
  }
}
