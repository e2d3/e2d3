define ['text'], (text) ->
  'use strict';

  generate = (src, modules) ->
    nameMap =
      jquery: '$'
      lodash: '_'
      react: 'React'

    moduleNameMap = (module) ->
      idx = module.indexOf('=')
      if idx != -1
        module[0...idx]
      else
        nameMap[module] ? module

    moduleMap = (module) ->
      idx = module.indexOf('=')
      if idx != -1
        "'#{module[(idx+1)..-1]}'"
      else
        "'#{module}'"

    moduleNames = modules.map(moduleNameMap).join(',')
    moduleNamesWithQuote = modules.map(moduleMap).join(',')

    wrapped = """
define([#{moduleNamesWithQuote}], function (#{moduleNames}) {

  var _script = function (root, baseUrl, reload) {

////
//// ORIGINAL SCRIPT START
////

#{src}

////
//// ORIGINAL SCRIPT END
////

    var _functions = {};
    if (typeof update !== 'undefined') _functions.update = update;
    if (typeof save !== 'undefined') _functions.save = save;
    return _functions;
  }

  return function (root, baseUrl) {
    var _data = null;
    var _functions = null;

    var _reload = function () {
      if (_data && _functions.update) {
        _functions.update(_data);
      }
    };

    var _initialize = function () {
      _functions = _script(root, baseUrl, _reload);
      _reload();
    };

    var _dispose = function () {
      d3.select(root).selectAll('*').remove();
    };

    _initialize();

    var exports = {
      update: function (data) {
        _data = data;
        _reload();
      },
      resize: function () {
        _dispose();
        _initialize();
      },
      save: function () {
        if (_functions.save) {
          return _functions.save();
        } else {
          return d3.select(root).select('svg');
        }
      }
    };

    return exports;
  };
});
"""
    wrapped

  transform = (content, firstLine) ->
    # extract module names
    if matched = firstLine.match /^\/\/#\s*require\s*=\s*(.*)$/
      modules = matched[1].split(',').map (module) -> module.trim()
    else if matched = firstLine.match /^##\s*require\s*=\s*(.*)$/
      modules = matched[1].split(',').map (module) -> module.trim()
    else
      modules = ['d3']
    generate content, modules

  compileJavaScript = (req, content, callback) ->
    lines = content.split /\r\n|\r|\n/
    vlqs = for i in [0...lines.length]
      if i == 0 then 'AAAA' else 'AACA'
    script = content
    mappings = vlqs.join ';'
    callback script, mappings

  compileCoffeeScript = (req, content, callback) ->
    req ['coffee-script'], (CoffeeScript) ->
      options = bare: true, header: false, inline: true, sourceMap: true
      compiled = CoffeeScript.compile(content, options)
      script = compiled.js
      mappings = JSON.parse(compiled.v3SourceMap).mappings
      callback script, mappings

  compileJSX = (req, content, callback) ->
    req ['JSXTransformer'], (JSXTransformer) ->
      compiled = JSXTransformer.transform content, sourceMap: true
      script = compiled.code
      mappings = compiled.sourceMap.mappings
      callback script, mappings

  e2d3loader =
    version: '0.4.0'

    load: (name, req, onLoadNative, config) ->
      onLoad = (content) ->
        compile =
          if /.coffee$/.test name
            compileCoffeeScript
          else if /.jsx$/.test name
            compileJSX
          else
            compileJavaScript

        compile req, content, (compiled, mappings) ->
          firstLine = (/[^\r\n]+/.exec(content))?[0]

          transformed = transform compiled, firstLine
          transformedMappings = ';;;;;;;;' + mappings

          sourceMap =
            version: 3
            file: 'evaluated'
            sourceRoot: config.baseUrl
            sources: [name]
            sourcesContent: [content]
            names: []
            mappings: transformedMappings

          encodedSourceMap = btoa unescape encodeURIComponent JSON.stringify sourceMap
          transformed += "\n//# sourceURL=" + name
          transformed += "\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,#{encodedSourceMap}"

          onLoadNative.fromText transformed

      onLoad.error = (err) -> onLoadNative.error err

      text.load(name, req, onLoad, config);

  e2d3loader
