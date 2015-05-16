define ['text', 'compiler'], (text, compiler) ->
  'use strict';

  wrap = (compiled, firstLine) ->
    # extract module names
    if matched = firstLine.match /^\/\/#\s*require\s*=\s*(.*)$/
      modules = matched[1].split(',').map (module) -> module.trim()
    else if matched = firstLine.match /^##\s*require\s*=\s*(.*)$/
      modules = matched[1].split(',').map (module) -> module.trim()
    else
      modules = ['d3']

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

#{compiled}

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

  e2d3loader =
    version: '0.4.0'

    load: (name, req, onLoadNative, config) ->
      onLoad = (source) ->
        compiler.compile req, name, source, (compiled, mappings) ->
          firstLine = (/[^\r\n]+/.exec(source))?[0]

          wrapped = wrap compiled, firstLine
          wrappedMappings = ';;;;' + mappings

          transformed = compiler.mapping wrapped, name, source, wrappedMappings, config.baseUrl

          onLoadNative.fromText transformed

      onLoad.error = (err) -> onLoadNative.error err

      text.load(name, req, onLoad, config);

  e2d3loader
