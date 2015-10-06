define [], () ->

  extractModules = (name, source) ->
    r =
      if /.coffee$/.test name
        /^##\s*require\s*=(.*)$/gm
      else
        /^\/\/#\s*require\s*=(.*)$/gm

    ret = []
    while m = r.exec(source)
      modules = m[1].split(',').map (module) -> module.trim()
      ret = ret.concat modules
    ret

  extractConfig = (name, source) ->
    r =
      if /.coffee$/.test name
        /^###\s*config\s*=([\s\S]*?)###/gm
      else
        /^\/\*#\s*config\s*=([\s\S]*?)\*\//gm

    ret = paths: {}, shim: {}, map: {}
    while m = r.exec(source)
      e = eval
      config =
        try
          e "(#{m[1]})"
        catch ex
          console.error '[E2D3] Error on extracting config comments:', ex
          {}
      for own prop of ret
        continue if !config[prop]?
        for own key, value of config[prop]
          ret[prop][key] = value
    ret

  ###
  # exports
  ###
  extractor =
    modules: extractModules
    config: extractConfig

  extractor
