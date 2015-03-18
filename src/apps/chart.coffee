params = window.location.hash.substring(1).split ','

# HACKED: prevent LiveReload shutdowning parent's LiveReload
document.addEventListener 'LiveReloadConnect', () ->
  LiveReload.__proto__.shutDown = () ->
    # noop

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

  chart = () -> _frame?.contentWindow?.chart

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
            undefined # cofeescript promise idiom
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
            chart().update data
            undefined # cofeescript promise idiom
          .catch (err) ->
            e2d3.onError err
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
    $('#e2d3-save-svg').on 'click', (e) ->
      e.preventDefault()
      node = chart().save().node()
      e2d3.util.save chart().save().node(), 'svg', _baseUrl if node
    $('#e2d3-save-png').on 'click', (e) ->
      e.preventDefault()
      node = chart().save().node()
      e2d3.util.save chart().save().node(), 'png', _baseUrl if node

    # for development
    if !e2d3.util.isExcel() && e2d3.util.isStandalone()
      fill()
    else
      fill()

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
