define [], () ->
  DEFAULT_CAPABILITIES =
    selectColorThemes: false
    saveImages: true

  extract: (capabilities) ->
    result = DEFAULT_CAPABILITIES

    if capabilities?
      for key, value of result
        result[key] = capabilities[key] ? result[key]

    console.info "[E2D3] capabilities: #{JSON.stringify(result)}"

    result
