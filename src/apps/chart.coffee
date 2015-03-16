params = window.location.hash.substring(1).split ','

###
# load parameters
###
_baseUrl = params[0]
_main = switch params[1]
  when 'jsx' then 'main.jsx'
  when 'coffee' then 'main.coffee'
  else 'main.js'
_dataType = params[2]

require ['domReady!', 'bootstrap', 'jquery', 'd3', 'd3.promise', 'FileSaver', 'canvg', 'e2d3'], (domReady, bootstrap, $, d3, d3Promise, saveAs, canvg, e2d3) ->
  $('[data-toggle="tooltip"]').tooltip()

  createFrame = () ->
    iframe = document.createElement 'iframe'
    iframe.src = 'frame.html' + window.location.hash
    iframe.width = '100%'
    iframe.height = '100%'
    iframe.frameBorder = 0
    iframe.scrolling = 'no'
    iframe.sandbox = 'allow-same-origin allow-scripts'
    return iframe

  initialize = () ->
    _binding = null

    ###
    # bindingの初期化
    ###
    setupBinding = (binding) ->
      oldbinding = _binding
      _binding = binding
      _binding.on 'change', renderBinding
      renderBinding()
      if oldbinding?
        oldbinding.release()
          .then () ->
            undefined
          .catch (err) ->
            e2d3.onError err

    ###
    # bindingの描画
    #
    # bindingからデータを取り出し描画する
    ###
    renderBinding = () ->
      if _binding
        _binding.fetchData()
          .then (data) ->
            _frame.contentWindow.update data
      else
        _frame.contentWindow.update e2d3.data.empty()

    fill = () ->
      d3.promise.text _baseUrl + '/data.' + _dataType
        .then (text) ->
          e2d3.excel.fill _dataType, text
        .then () ->
          e2d3.excel.bindSelected()
        .then (binding) ->
          setupBinding binding
          undefined # cofeescript promise idiom
        .catch (err) ->
          e2d3.onError err

    rebind = () ->
      e2d3.excel.bindSelected()
        .then (binding) ->
          setupBinding binding
          undefined # cofeescript promise idiom
        .catch (err) ->
          e2d3.onError err


    save = (type) ->
      svg = _frame.contentWindow.save().node()
      d3.select(svg)
        .attr
          version: '1.1'
          xmlns: 'http://www.w3.org/2000/svg'
      width = d3.select(svg).attr 'width'
      height = d3.select(svg).attr 'height'

      svgxml = new XMLSerializer().serializeToString(svg)

      switch type
        when 'svg' then saveAs toBlobSVG(svgxml), 'image.svg'
        when 'png' then saveAs toBlobPNG(svgxml, width, height), 'image.png'

    toBlobSVG = (svg) ->
      new Blob [svg], type: 'image/svg+xml;charset=utf-8'

    toBlobPNG = (svg, width, height) ->
      canvas = document.createElement 'canvas'
      canvg canvas, svg
      dataUrlToBlob canvas.toDataURL 'image/png'

    dataUrlToBlob = (url) ->
      [all, type, base64] = url.match /^data:(.*);base64,(.*)$/
      bin = atob base64
      buffer = new Uint8Array bin.length
      buffer[i] = bin.charCodeAt i for i in [0...bin.length]
      new Blob [buffer.buffer], type: type

    $('#e2d3-rebind').on 'click', (e) -> rebind()
    $('#e2d3-save-svg').on 'click', (e) ->
      e.preventDefault()
      save 'svg'
    $('#e2d3-save-png').on 'click', (e) ->
      e.preventDefault()
      save 'png'

    # for development
    if !e2d3.util.isExcel() && e2d3.util.isStandalone()
      fill()
    else
      fill()

  _frame = createFrame()

  frameReadyPromise = new Promise (resolve, reject) -> $(_frame).on 'load', () -> resolve()
  excelReadyPromise = e2d3.initialize()

  $('#e2d3-frame').append _frame

  Promise.all [frameReadyPromise, excelReadyPromise]
    .then initialize
