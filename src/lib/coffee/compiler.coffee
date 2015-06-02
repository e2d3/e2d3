define [], () ->

  compileJavaScript = (req, source, callback) ->
    lines = source.split /\r\n|\r|\n/
    vlqs = for i in [0...lines.length]
      if i == 0 then 'AAAA' else 'AACA'
    script = source
    mappings = vlqs.join ';'
    callback script, mappings

  compileCoffeeScript = (req, source, callback) ->
    req ['coffee-script'], (CoffeeScript) ->
      options = bare: true, header: false, inline: true, sourceMap: true
      compiled = CoffeeScript.compile(source, options)
      script = compiled.js
      mappings = JSON.parse(compiled.v3SourceMap).mappings
      callback script, mappings

  compileJSX = (req, source, callback) ->
    req ['JSXTransformer'], (JSXTransformer) ->
      compiled = JSXTransformer.transform source, sourceMap: true
      script = compiled.code
      mappings = compiled.sourceMap.mappings
      callback script, mappings

  ###
  # exports
  ###
  compiler =
    compile: (req, name, source, callback) ->
      compile =
        if /.coffee$/.test name
          compileCoffeeScript
        else if /.jsx$/.test name
          compileJSX
        else
          compileJavaScript

      compile req, source, callback

    mapping: (compiled, name, source, mappings, baseUrl) ->
      sourceMap =
        version: 3
        file: 'evaluated'
        sourceRoot: baseUrl
        sources: [name]
        sourcesContent: [source]
        names: []
        mappings: mappings

      encodedSourceMap = btoa unescape encodeURIComponent JSON.stringify sourceMap
      compiled += "\n//# sourceURL=" + name
      compiled += "\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,#{encodedSourceMap}"
      compiled

  compiler
