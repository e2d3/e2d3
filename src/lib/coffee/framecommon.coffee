define [], () ->

  cssloaded = false
  dataupdated = false

  takeScreenShot = () ->
    if dataupdated && cssloaded
      console.log '[E2D3] take screenshot'
      if typeof window.callPhantom == 'function'
        setTimeout () ->
          window.callPhantom 'takeShot'
        , 0

  common =
    loadMainCss: (onload) ->
      # load css, please ignore 404 error
      css = document.createElement('link')
      css.rel = 'stylesheet'
      css.type = 'text/css'
      css.href = 'main.css'
      # PhantomJS currently does not support 'onload' event for stylesheets
      # see https://github.com/ariya/phantomjs/issues/12332
      css.onload = css.onerror = window.onmaincssload = window.onmaincsserror = () ->
        console.log '[E2D3] css loaded'
        cssloaded = true
        takeScreenShot()
        onload?()
      document.querySelector('head').appendChild(css)

    onDataUpdated: () ->
      console.log '[E2D3] data updated'
      dataupdated = true
      takeScreenShot()

  common
