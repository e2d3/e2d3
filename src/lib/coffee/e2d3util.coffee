define ['jquery', 'd3', 'd3.promise', 'FileSaver', 'canvg'], ($, d3, d3Promise, saveAs, canvg) ->
  # this works only on top frame
  isNativeExcel =
    try
      window.external.GetContext()?
    catch err
      false

  isOffice365Excel =
    window.parent != window

  class E2D3Util
    isExcel: () ->
      isNativeExcel || isOffice365Excel

    isDelegateMode: () ->
      !!(sessionStorage.getItem('delegate'))

    setDelegateMode: (value) ->
      if value
        sessionStorage.setItem 'delegate', true
      else
        sessionStorage.removeItem 'delegate'

    isDebugConsoleEnabled: () ->
      isNativeExcel && @isDelegateMode()

    isLiveReloadEnabled: () ->
      @isExcel() && @isDelegateMode()

    save: (svgnode, type, baseUrl, filename='image') ->
      return if !svgnode?
      d3.promise.text "#{baseUrl}/main.css"
        .then (css) =>
          @saveWithCSS svgnode, type, baseUrl, filename, css
        .catch (err) =>
          @saveWithCSS svgnode, type, baseUrl, filename, null

    saveWithCSS: (svgnode, type, basUrl, filename, css) ->
      width = d3.select(svgnode).attr 'width'
      height = d3.select(svgnode).attr 'height'

      svgnode = svgnode.cloneNode true

      d3.select(svgnode)
        .attr version: '1.1', xmlns: 'http://www.w3.org/2000/svg'
        .insert 'defs', ':first-child'

      svgxml = new XMLSerializer().serializeToString(svgnode)
      svgxml = svgxml.replace /<defs ?\/>/, """<defs><style type="text/css"><![CDATA[#{css}]]></style></defs>""" if css?

      switch type
        when 'svg' then saveAs @toBlobSVG(svgxml), "#{filename}.svg"
        when 'png' then saveAs @toBlobPNG(svgxml, width, height), "#{filename}.png"

    toBlobSVG: (svg) ->
      new Blob [svg], type: 'image/svg+xml;charset=utf-8'

    toBlobPNG: (svg, width, height) ->
      canvas = document.createElement 'canvas'
      canvg canvas, svg
      @dataUrlToBlob canvas.toDataURL 'image/png'

    dataUrlToBlob: (url) ->
      [all, type, base64] = url.match /^data:(.*);base64,(.*)$/
      bin = atob base64
      buffer = new Uint8Array bin.length
      buffer[i] = bin.charCodeAt i for i in [0...bin.length]
      new Blob [buffer.buffer], type: type

    ###*
    # change `console.log()`'s output to popup dialog
    ###
    setupDebugConsole: () ->
      $('#log').on 'click', () ->
        clearTimeout $('#log').data 'timer'
        $('#log').stop(true, true).fadeOut(100)

      print = (msg) ->
        return if (msg + '').indexOf('Agave.HostCall.') == 0

        $('#log').append($('<div>').text(JSON.stringify(msg)))

        # you can't use `$.delay()`
        # http://stackoverflow.com/questions/3329197/jquery-delay-or-timeout-with-stop
        clearTimeout($('#log').data('timer'))
        $('#log').stop(true, true)
          .fadeIn 100, () ->
            $('#log').get(0).scrollTop = $('#log').get(0).scrollHeight
            $('#log').data 'timer', setTimeout () ->
              $('#log').stop(true, true).fadeOut(500)
            , 5000

      window.onerror = (message, url, line) ->
        print "#{message} (#{url}:#{line})"

      console.log = print
      console.info = print
      console.error = print

    setupLiveReload: () ->
      $.getScript 'https://localhost:8443/livereload.js?snipver=1'

  new E2D3Util()
