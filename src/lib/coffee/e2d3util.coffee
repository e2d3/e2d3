define ['params!', 'jquery', 'd3', 'FileSaver', 'canvg'], (params, $, d3, saveAs, canvg) ->
  class E2D3Util
    isExcel: () ->
      !!Office.context.document

    isDevelopment: () ->
      $('script[src*="livereload.js"]').length != 0

    isStandalone: () ->
      $('script[src*=":35730/livereload.js"]').length != 0

    isDebugEnabled: () ->
      params.debug? && @isExcel()

    urlParam: (name) ->
      results = new RegExp("[\?&]#{name}(=([^&#]*))?").exec(window.location.search);
      if results == null then null else results[2]

    save: (svgnode, type, filename='image') ->
      # should deep-clone node (but cannot on IE)
      d3.select(svgnode)
        .attr
          version: '1.1'
          xmlns: 'http://www.w3.org/2000/svg'
      width = d3.select(svgnode).attr 'width'
      height = d3.select(svgnode).attr 'height'

      svgxml = new XMLSerializer().serializeToString(svgnode)

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

  new E2D3Util()
