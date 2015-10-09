define ['text', 'loader/compiler', 'loader/extractor'], (text, compiler, extractor) ->
  'use strict'

  wrap = (compiled, modules) ->
    modules = ['d3'] if modules.length == 0

    nameMap =
      jquery: '$'
      lodash: '_'
      react: 'React'
      vue: 'Vue'
      'three.js': 'THREE'

    toVariable = (s) ->
      s
        .replace(/(\-\w)/g, (m) -> m[1].toUpperCase())
        .replace('.', '')

    moduleNameMap = (module) ->
      idx = module.indexOf(':')
      if idx != -1
        "'#{module[(idx+1)..-1]}'"
      else
        "'#{module}'"

    moduleVariableMap = (module) ->
      idx = module.indexOf(':')
      if idx != -1
        module[0...idx]
      else
        nameMap[module] ? toVariable(module)

    moduleNames = modules.map(moduleNameMap).join(',')
    moduleVariables = modules.map(moduleVariableMap).join(',')

    console.info "[E2D3] define([#{moduleNames}], function (#{moduleVariables}) { ... });"

    wrapped = """
define([#{moduleNames}], function (#{moduleVariables}) {

  var _script = function (e2d3, root, baseUrl, reload, onready) {

#{compiled}

    var _functions = {};
    if (typeof update !== 'undefined') _functions.update = update;
    if (typeof save !== 'undefined') _functions.save = save;
    return _functions;
  }

  return function (root, baseUrl) {
    var _data = null;
    var _onready = null;
    var _functions = null;

    var _reload = function () {
      if (_data && _functions.update) {
        var result = _functions.update(_data);
        if (!(typeof result === 'boolean' && result === false)) {
          if (_onready) {
            _onready();
          }
        }
      }
    };

    var _ready = function () {
      if (_onready) {
        _onready();
      }
    }

    var _initialize = function () {
      var e2d3 = {
        root: root,
        baseUrl: baseUrl,
        reload: _reload,
        onready: _ready
      };

      _functions = _script(e2d3, root, baseUrl, _reload, _ready);
      _reload();
    };

    var _dispose = function () {
      d3.select(root).selectAll('*').remove();
    };

    _initialize();

    var exports = {
      update: function (data, onready) {
        _data = data;
        _onready = onready;
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
        modules = extractor.modules name, source
        overrides = extractor.config name, source

        console.info "[E2D3] modules: #{JSON.stringify(modules)}"
        console.info "[E2D3] config: #{JSON.stringify(overrides, null, '  ')}"

        # copy configs from overrides
        for own prop of overrides
          for own key, value of overrides[prop]
            config[prop][key] = value

        compiler.compile req, name, source, (compiled, mappings) ->
          wrapped = wrap compiled, modules
          wrappedMappings = ';;;;' + mappings

          transformed = compiler.mapping wrapped, name, source, wrappedMappings, config.baseUrl

          onLoadNative.fromText transformed

      onLoad.error = (err) -> onLoadNative.error err

      text.load(name, req, onLoad, config)

  e2d3loader
