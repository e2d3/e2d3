params = window.location.hash.substring 1
  .split ','

_baseUrl = params[0]
_main = if params[1] == 'coffee' then 'cs!main' else 'main'
_dataType = params[2]

require.config
  baseUrl: _baseUrl

require ['domReady', 'bootstrap', 'jquery', 'd3', 'd3.promise', 'queue', 'e2d3', _main], (domReady, bootstrap, $, d3, d3Promise, queue, e2d3, main) ->
  e2d3.initialize()
    .then (reason) ->
      domReady initialize
      undefined # cofeescript promise idiom
    .catch (err) ->
      e2d3.onError err

  initialize = () ->
    _chart = $('#chart').get(0)
    _main = main _chart, _baseUrl
    _binding = null

    renderBinding = () ->
      if _binding
        _binding.fetchData (data) ->
          _main.update data
      else
        _main.update e2d3.data.empty()

    setupBinding = (binding) ->
      _binding = binding
      _binding.on 'change', renderBinding
      renderBinding()

    $(window).on 'resize', () ->
      _main.resize() if _main.resize

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
