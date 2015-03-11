define ['text'], (text) ->
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

    return update;
  }

  return function (node, baseUrl) {
    var _data = null;
    var _update = null;

    var _reload = function () {
      if (_data && _update) {
        _update(_data);
      }
    };

    var _initialize = function () {
      _update = _script(node, baseUrl, _reload);
      _reload();
    };

    var _dispose = function () {
      d3.select(node).selectAll('*').remove();
    };

    _initialize();

    var exports = {
      update: function (data) {
        _data = data;
        _reload();
      },
      resize: function(data) {
        _dispose();
        _initialize();
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
      req ['coffee-script', 'JSXTransformer'], (CoffeeScript, JSXTransformer) ->
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
