define ['text', 'coffee-script'], (text, CoffeeScript) ->
  'use strict';

  generate = (src, modules) ->
    moduleMap = (module) ->
      switch module
        when 'jquery' then '$'
        when 'lodash' then '_'
        when 'react' then 'React'
        else module

    moduleNames = modules.map(moduleMap).join(',')
    moduleNamesWithQuote = modules.map((module) -> "'#{module}'").join(',')

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
          firstLine = (content.split /\r\n|\r|\n/)[0]

          try
            if /.coffee$/.test name
              options = bare: true, header: false, inline: true
              content = CoffeeScript.compile(content, options)
            else if /.jsx$/.test name
              options = {}
              content = JSXTransformer.transform(content, options).code
          catch err
            onLoadNative.error err

          content = transform content, firstLine

          onLoadNative.fromText content

        onLoad.error = (err) -> onLoadNative.error err

        text.load(name, req, onLoad, config);

  e2d3loader
