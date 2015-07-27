define [], () ->

  cssloaded = false
  dataupdated = false

  takeScreenShot = () ->
    if dataupdated && cssloaded
      console.log '[E2D3] takeShot'
      if typeof window.callPhantom == 'function'
        setTimeout () ->
          window.callPhantom 'takeShot'
        , 0

  common =
    loadMainCss: () ->
      # load css, please ignore 404 error
      css = document.createElement('link')
      css.rel = 'stylesheet'
      css.type = 'text/css'
      css.href = 'main.css'
      # PhantomJS currently does not support 'onload' event for stylesheets
      # see https://github.com/ariya/phantomjs/issues/12332
      css.onload = css.onerror = window.onmaincssload = window.onmaincsserror = () ->
        console.log '[E2D3] cssLoaded'
        cssloaded = true
        takeScreenShot()
      document.querySelector('head').appendChild(css)

    onDataUpdated: () ->
      console.log '[E2D3] dataUpdated'
      dataupdated = true
      takeScreenShot()

  common
