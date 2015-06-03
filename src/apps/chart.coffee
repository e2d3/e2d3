params = window.location.hash.substring(1).split ','

###
# load parameters
###
_baseUrl = params[0] ? '.'
_scriptType = params[1] ? 'js'
_dataType = params[2] ? 'csv'

require ['domReady!', 'bootstrap', 'jquery', 'd3', 'd3.promise', 'e2d3'], (domReady, bootstrap, $, d3, d3Promise, e2d3) ->
  e2d3.util.setupLiveReload() if e2d3.util.isLiveReloadEnabled()

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

  chart = () -> _frame?.contentWindow?.chart
  debug = () -> _frame?.contentWindow?.debug

  initialize = () ->
    _binding = null

    debug().setupDebugConsole() if e2d3.util.isDebugConsoleEnabled()

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
            undefined # cofeescript promise idiom
          .catch onError

    ###
    # bindingの描画
    #
    # bindingからデータを取り出し描画する
    ###
    renderBinding = () ->
      if _binding
        _binding.fetchData()
          .then (data) ->
            chart().update data
            undefined # cofeescript promise idiom
          .catch onError
      else
        chart().update e2d3.data.empty()

    fill = () ->
      d3.promise.text "#{_baseUrl}/data.#{_dataType}"
        .then (text) ->
          e2d3.excel.fill _dataType, text
        .then () ->
          e2d3.excel.bindSelected()
        .then (binding) ->
          setupBinding binding
          $('#e2d3-fill-sample').hide()
          undefined # cofeescript promise idiom
        .catch (err) ->
          onError err
          $('#e2d3-fill-sample').show()

    rebind = () ->
      e2d3.excel.bindSelected()
        .then (binding) ->
          setupBinding binding
          undefined # cofeescript promise idiom
        .catch onError

    $('#e2d3-rebind').on 'click', (e) -> rebind()
    $('#e2d3-fill-sample').on 'click', (e) -> fill()
    $('#e2d3-save-svg').on 'click', (e) ->
      e.preventDefault()
      node = chart().save().node()
      e2d3.util.save chart().save().node(), 'svg', _baseUrl if node
    $('#e2d3-save-png').on 'click', (e) ->
      e.preventDefault()
      node = chart().save().node()
      e2d3.util.save chart().save().node(), 'png', _baseUrl if node

    fill()

  onError = (err) ->
    showAlert err.name, err.message if err.code?
    e2d3.onError err

  showAlert = (title, message) ->
    $('#e2d3-alert-title').text(title)
    $('#e2d3-alert-body').text(message)
    $('#e2d3-alert').modal()

  _frame = createFrame()

  frameReadyPromise = new Promise (resolve, reject) ->
    checkframe = () ->
      if chart()?
        resolve()
      else
        setTimeout checkframe, 100
    checkframe()

  excelReadyPromise = e2d3.initialize()

  $('#e2d3-frame').append _frame

  Promise.all [frameReadyPromise, excelReadyPromise]
    .then initialize
