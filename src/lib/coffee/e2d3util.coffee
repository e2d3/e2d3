define ['params!', 'jquery', 'd3', 'd3.promise', 'FileSaver', 'canvg'], (params, $, d3, d3Promise, saveAs, canvg) ->
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

  new E2D3Util()
