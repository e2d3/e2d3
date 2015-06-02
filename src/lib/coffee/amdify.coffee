define ['text', 'compiler'], (text, compiler) ->
  'use strict';

  wrap = (compiled, exports) ->
    wrapped = """
define([], function () {
  #{compiled};
  return #{exports};
});
"""
    wrapped

  e2d3loader =
    version: '0.4.0'

    load: (name, req, onLoadNative, config) ->
      idx = name.indexOf(':')
      exports = name[0...idx]
      name = name[idx+1..-1]

      onLoad = (source) ->
        compiler.compile req, name, source, (compiled, mappings) ->
          wrapped = wrap compiled, exports
          wrappedMappings = ';' + mappings

          transformed = compiler.mapping wrapped, name, source, wrappedMappings, config.baseUrl

          onLoadNative.fromText transformed

      onLoad.error = (err) -> onLoadNative.error err

      text.load(name, req, onLoad, config);

  e2d3loader
