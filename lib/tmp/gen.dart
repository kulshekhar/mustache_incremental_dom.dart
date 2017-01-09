import 'package:mustache_playground/generate.dart';

void main() {
  generate(t);
}

const t = '''
    <H1> projects heading </h1>
      {{#items}}
        Items: {{.}}
        {{itemName}}
        {{#cities}}
          {{cityName}}
        {{/cities}}
      {{/items}}
    <div class="row">
      {{#projects}}
        <a href="{{url}}" class="block">
          <h2> {{name}} </h2>
          <p> {{description}} </p>
        </a>
      {{/projects}}
    </div>
    <h3>Today{{! ignore me }}.</h3>
    {{^repo}}
      No repos :(
    {{/repo}}
    <custom-component att1=33>something</custom-component>
    <img id=i1 s:data-custom='cc' src='http://example1.com'>
    <img src='http://example2.com' />

    <div>Hello {{firstname}}</div>

    <div>Hello {{& somevar}}</div>

    {{#things}}
      {{id}}
    {{/things}}

    {{{unescapedVariable}}}

    <div class="back">
      <a href="/">
      &#8617;
      </a>
    </div>
''';
