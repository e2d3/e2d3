define ['text', 'coffee-script', 'vlq'], (text, CoffeeScript, vlq) ->
  'use strict';

  generate = (src, modules) ->
    nameMap =
      jquery: '$'
      lodash: '_'

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

    """
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

  transform = (content, firstLine) ->
    # extract module names
    if matched = firstLine.match /^\/\/#\s*require\s*=\s*(.*)$/
      modules = matched[1].split(',').map (module) -> module.trim()
    else if matched = firstLine.match /^##\s*require\s*=\s*(.*)$/
      modules = matched[1].split(',').map (module) -> module.trim()
    else
      modules = ['d3']
    generate content, modules

  e2d3loader =
    version: '0.4.0'

    load: (name, req, onLoadNative, config) ->
      req ['JSXTransformer'], (JSXTransformer) ->
        onLoad = (content) ->
          lines = content.split /\r\n|\r|\n/
          mappingsPrefix = ';;;;;;;;'

          srcmap =
            version: 3
            file: 'evaluated'
            sourceRoot: config.baseUrl
            sources: [name]
            sourcesContent: [content]
            names: []

          try
            if /.coffee$/.test name
              options =
                bare: true
                header: false
                inline: true
                sourceMap: true
              compiled = CoffeeScript.compile(content, options)
              content = compiled.js
              originalSourceMap = JSON.parse(compiled.v3SourceMap)
              srcmap.mappings = mappingsPrefix + originalSourceMap.mappings
            else if /.jsx$/.test name
              compiled = JSXTransformer.transform content, sourceMap: true
              content = compiled.code
              srcmap.mappings = mappingsPrefix + compiled.sourceMap.mappings
            else
              vlqs = for i in [0...lines.length]
                diff = if i == 0 then 0 else 1
                vlq.encode [0, 0, diff, 0]
              srcmap.mappings = mappingsPrefix + vlqs.join ';'
          catch err
            console.error err

          content = transform content, lines[0]

          sourceMapping = btoa unescape encodeURIComponent JSON.stringify srcmap
          content += "\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,#{sourceMapping}"

          onLoadNative.fromText content

        onLoad.error = (err) -> onLoadNative.error err

        text.load(name, req, onLoad, config);

  e2d3loader
