library hello_world;

import 'package:mustache_incremental_dom/generator/template.dart';
import 'package:incremental_dom_facade/incremental_dom_facade.dart';
import 'dart:js' show allowInterop;
import 'dart:html' show Element, InputElement, Event;

part 'hello_world.g.dart';

@Template(templateUrl: 'hello_world.html')
class HelloWorld {
  HelloWorldData _data;
  Element _parent;

  HelloWorld(this._parent, this._data) {
    // _handleChanges();
    _data.onNameChange(onNameChange);
  }

  show() {
    _patch();
  }

  _patch() {
    patch(_parent, render, _data);
  }

  onNameChange(Symbol s, String oldValue, String newValue) {
    if (oldValue != newValue) {
      _patch();
    }
  }

  // _handleChanges() {
  //   _data.changes.listen((List<PropertyChangeRecord> l) {
  //     if (l.firstWhere((r) => r.oldValue != r.newValue, orElse: () => null) !=
  //         null) {
  //       _patch();
  //     }
  //   });
  // }
}

class HelloWorldData {
  String id = 'inp1';
  String _name = '';
  String _originalName = '';
  int age = 22;
  String address = 'Some address';
  Function _onNameChange;

  String get name => _name;
  set name(String value) {
    String oldValue = _name;
    _name = value;
    if (_onNameChange != null) {
      _onNameChange(#name, oldValue, value);
    }
  }

  HelloWorldData(this._name) {
    _originalName = _name;
  }

  onNameChange(Function h) {
    _onNameChange = h;
  }

  onH1Click(Event e) {
    print('h1 clicked');
  }

  onAgeClick(Event e) {
    print('age clicked');
  }

  onInput(Event e) {
    InputElement i = e.target;
    name = i.value;
  }

  reset(Event e) {
    name = _originalName;
  }
}
