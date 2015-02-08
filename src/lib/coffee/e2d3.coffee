define ['params!', 'd3', 'jquery', 'e2d3api', 'e2d3model'], (params, d3, $, api, model) ->
  ChartDataTable = model.ChartDataTable

  class Binding
    constructor: (@binding) ->

    on: (event, handler) ->
      if event == 'change'
        @binding.addHandlerAsync Office.EventType.BindingDataChanged, handler

    fetchData: () ->
      new Promise (resolve, reject) =>
        @binding.getDataAsync valueFormat: Office.ValueFormat.Unformatted, (result) ->
          if result.status == Office.AsyncResultStatus.Succeeded
            resolve new ChartDataTable result.value
          else
            resolve new ChartDataTable []

  class DummyBinding
    constructor: (@data) ->

    on: (event, handler) ->

    fetchData: () ->
      new Promise (resolve, reject) =>
        resolve new ChartDataTable @data

  ###*
  # if '?debug' parameter is specified
  # change `console.log()`'s output to popup dialog
  ###
  setConsoleToPopup = () ->
    return if !e2d3.util.isDebugEnabled()

    $('#log').on 'click', () ->
      clearTimeout $('#log').data 'timer'
      $('#log').stop(true, true).fadeOut(100)

    print = (msg) ->
      return if (msg + '').indexOf('Agave.HostCall.') == 0

      $('#log').append($('<div>').text(msg + ''))

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

  ###
  # export
  ###

  ###*
  # Initialize
  # Must call this function in page. if you need some action, you can callback function.
  ###
  e2d3 =
    initialize: () ->
      setConsoleToPopup()

      new Promise (resolve, reject) ->
        timer = setTimeout () ->
          console.log 'initialized: browser'
          resolve Office.InitializationReason.Inserted
        , 1000

        Office.initialize = (reason) ->
          clearTimeout timer
          console.log 'initialized: excel'
          resolve reason

    onError: (message) ->
      if message?.stack?
        console.log message, message.stack
      else
        console.log message

    excel:
      fill: (type, text, callback) ->
        new Promise (resolve, reject) ->
          rows = d3[type].parseRows text

          if e2d3.util.isExcel()
            Office.context.document.setSelectedDataAsync rows, coercionType: Office.CoercionType.Matrix, (result) ->
              if result.status == Office.AsyncResultStatus.Succeeded
                resolve null
              else
                reject result.error
          else
            resolve rows

      bindSelected: (selection, callback) ->
        new Promise (resolve, reject) ->
          if e2d3.util.isExcel()
            Office.context.document.bindings.addFromSelectionAsync Office.BindingType.Matrix, (result) ->
              if result.status == Office.AsyncResultStatus.Succeeded
                resolve new Binding result.value
              else
                reject result.error
          else
            resolve new DummyBinding selection

      bindPrompt: (callback) ->
        new Promise (resolve, reject) ->
          Office.context.document.bindings.addFromPromptAsync Office.BindingType.Matrix, (result) ->
            if result.status == Office.AsyncResultStatus.Succeeded
              resolve new Binding result.value
            else
              reject result.error

    data:
      empty: () -> new ChartDataTable []

    api: api

    util:
      isExcel: () ->
        !!Office.context.document

      isDevelopment: () ->
        $('script[src*="livereload.js"]').length != 0

      isStandalone: () ->
        $('script[src*=":35730/livereload.js"]').length != 0

      isDebugEnabled: () ->
        params.debug? && e2d3.util.isExcel()

      urlParam: (name) ->
        results = new RegExp("[\?&]#{name}(=([^&#]*))?").exec(window.location.search);
        if results == null then null else results[2]

  e2d3
