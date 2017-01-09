// Copyright (c) 2016, kulshekhar. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html' show ButtonElement, DivElement, MouseEvent, querySelector;

import 'package:mustache_incremental_dom/playground/hello_world.dart';
import 'package:incremental_dom_facade/incremental_dom_facade.dart'
    show attributes, applyProp;

final DivElement output = querySelector('#output');
final ButtonElement b1 = querySelector('#b1');
final ButtonElement b2 = querySelector('#b2');

final d1 = new HelloWorldData('person 1')
  ..age = 33
  ..address = 'some address';
final d2 = new HelloWorldData('person 2')
  ..age = 44
  ..address = 'some other address';
final HelloWorld h1 = new HelloWorld(output, d1);
final HelloWorld h2 = new HelloWorld(output, d2);

void main() {
  attributes['value'] = applyProp;
  handleButtonClick(b1, h1);
  handleButtonClick(b2, h2);
}

handleButtonClick(ButtonElement b, HelloWorld h) {
  b.onClick.any((MouseEvent e) {
    h.show();
  });
}
