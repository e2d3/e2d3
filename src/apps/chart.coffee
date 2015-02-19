params = window.location.hash.substring(1).split ','

###
# load parameters
###
_baseUrl = params[0]
_main = switch params[1]
  when 'jsx' then 'jsx!main'
  when 'coffee' then 'cs!main'
  else 'main'
_dataType = params[2]

###
# config
###
require.config
  baseUrl: _baseUrl
  paths:
    JSXTransformer: '/lib/JSXTransformer'
    jsx: '/lib/jsx'
  jsx:
    fileExtension: '.jsx'

###
# main routine
###
require ['domReady', 'bootstrap', 'jquery', 'd3', 'd3.promise', 'queue', 'e2d3', _main], (domReady, bootstrap, $, d3, d3Promise, queue, e2d3, main) ->
  # load css, please ignore 404 error
  $('<link rel="stylesheet" type="text/css" href="' + _baseUrl + '/main.css" >').appendTo 'head'

  e2d3.initialize()
    .then (reason) ->
      domReady initialize
      undefined # cofeescript promise idiom
    .catch (err) ->
      e2d3.onError err

  initialize = () ->
    _chart = main $('#chart').get(0), _baseUrl
    _binding = null

    ###
    # bindingの初期化
    ###
    setupBinding = (binding) ->
      _binding = binding
      _binding.on 'change', renderBinding
      renderBinding()

    ###
    # bindingの描画
    #
    # bindingからデータを取り出し描画する
    ###
    renderBinding = () ->
      if _binding
        _binding.fetchData()
          .then (data) ->
            _chart.update data
      else
        _chart.update e2d3.data.empty()

    $(window).on 'resize', () ->
      if _chart.resize?
        _binding.fetchData()
          .then (data) ->
            _chart.resize data

    $('#select').on 'click', ->
      e2d3.excel.bindPrompt()
        .then (binding) ->
          setupBinding binding
          undefined # cofeescript promise idiom
        .catch (err) ->
          e2d3.onError err

    $('#fill').on 'click', ->
      d3.promise.text _baseUrl + '/data.' + _dataType
        .then (text) ->
          e2d3.excel.fill _dataType, text
        .then (selection) ->
          e2d3.excel.bindSelected selection
        .then (binding) ->
          setupBinding binding
          undefined # cofeescript promise idiom
        .catch (err) ->
          e2d3.onError err

    $('#visualize').on 'click', ->
      console.log 'visualize'

    $('#reset').on 'click', ->
      console.log 'reset'

    # for development
    if !e2d3.util.isExcel() && e2d3.util.isStandalone()
      $('#fill').click()
    else
      $('#controller').show()
