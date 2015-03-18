define ['params!', 'jquery', 'd3', 'd3.promise', 'FileSaver', 'canvg'], (params, $, d3, d3Promise, saveAs, canvg) ->
  isExcel =
    try
      if window.external.GetContext()?
        true
      else
        false
    catch err
      false


  class E2D3Util
    isExcel: () ->
      isExcel

    isDevelopment: () ->
      $('script[src*="livereload.js"]').length != 0

    isStandalone: () ->
      $('script[src*=":35730/livereload.js"]').length != 0

    isDebugEnabled: () ->
      params.debug? && @isExcel()

    urlParam: (name) ->
      results = new RegExp("[\?&]#{name}(=([^&#]*))?").exec(window.location.search);
      if results == null then null else results[2]

    save: (svgnode, type, baseUrl, filename='image') ->
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
    # if '?debug' parameter is specified
    # change `console.log()`'s output to popup dialog
    ###
    setConsoleToPopup: () ->
      return if !@isDebugEnabled()

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
      console.error = print

  new E2D3Util()
