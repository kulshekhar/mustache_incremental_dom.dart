import 'dart:html';
import 'package:incremental_dom_facade/incremental_dom_facade.dart';

final DivElement output = querySelector('#output');

void handleButtons() {
  final d1 = new Data('data 1', true);
  final d2 = new Data('data 2', true);
  final d3 = new Data('data 3', false);

  querySelector('#b1').onClick.any((MouseEvent e) {
    patch(output, render, d1);
  });

  querySelector('#b2').onClick.any((MouseEvent e) {
    patch(output, (_) {
      render(d2);
    });
  });

  querySelector('#b3').onClick.any((MouseEvent e) {
    patch(output, (_) {
      render(d3);
    });
  });
}

render(Data data) {
  print(data);
  elementVoid('input', '', ['type', 'text']);

  elementOpen('div', '', null);
  text('Name');
  elementClose('div');

  elementOpen('div', '', null);
  if (data.isDone) {
    text(data.text);
  }
  elementClose('div');
}

class Data {
  String text = 'default text';
  bool isDone = false;
  Data([this.text, this.isDone]);

  toString() => '$text, $isDone';
}
