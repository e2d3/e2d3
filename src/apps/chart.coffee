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

require ['domReady!', 'bootstrap', 'jquery', 'd3', 'd3.promise', 'e2d3'], (domReady, bootstrap, $, d3, d3Promise, e2d3) ->
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

    $('#e2d3-rebind').on 'click', (e) -> rebind()

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
