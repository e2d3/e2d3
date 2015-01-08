define ['d3', 'jquery', 'e2d3api'], (d3, $, api) ->
  ###*
  # chart data.
  # field: head, rows
  ###
  class ChartData
    ###*
    # null chart data object.
    ###
    @empty: () ->
      new ChartData [], []

    ###*
    # array to chart data object.
    ###
    @fromArray: (array) ->
      head = array[0]
      rows = array.slice(1).map (row) ->
        obj = {}
        for key, i in head
          obj[key] = row[i]
        obj
      new ChartData head, rows

    ###*
    # chart data object constructor.
    ###
    constructor: (head, rows) ->
      @head = head
      @rows = rows

    ###*
    # chart data object to map.
    # key is first column value.
    ###
    toMap: ()->
      map = new ChartDataMap
      return map if @head.length == 0
      for row in @rows
        copy = $.extend {}, row
        delete copy[@head[0]]
        map[row[@head[0]]] = copy
      map

  ###*
  # chart data map form.
  # field: head, rows
  ###
  class ChartDataMap
    values: () ->
      values = []
      for own key, row of this
        for own name, value of row
          values.push +value
      values

  class Binding
    _binding = null

    constructor: (binding) ->
      _binding = binding

    on: (event, handler) ->
      if event == 'change'
        _binding.addHandlerAsync Office.EventType.BindingDataChanged, handler

    fetchData: (callback) ->
      _binding.getDataAsync valueFormat: Office.ValueFormat.Unformatted, (result) ->
        if result.status == Office.AsyncResultStatus.Succeeded
          callback ChartData.fromArray result.value
        else
          callback ChartData.empty()

  class DummyBinding
    _data = null

    constructor: (data) ->
      _data = data

    on: (event, handler) ->

    fetchData: (callback) ->
      callback _data

  ###*
  # if '?debug' parameter is specified
  # change `console.log()`'s output to popup dialog
  ###
  setConsoleToPopup = () ->
    # return if (e2d3.util.urlParam 'debug') == null

    $('#log').on 'click', () ->
      clearTimeout $('#log').data 'timer'
      $('#log').stop(true, true).fadeOut(100)

    print = (msg) ->
      return if msg.startsWith 'Agave.HostCall.'

      $('#log').append($('<div>').text(msg))

      # you can't use `$.delay()`
      # http://stackoverflow.com/questions/3329197/jquery-delay-or-timeout-with-stop
      clearTimeout($('#log').data('timer'))
      $('#log').stop(true, true)
        .fadeIn 100, () ->
          $('#log').get(0).scrollTop = $('#log').get(0).scrollHeight
          $('#log').data 'timer', setTimeout () ->
            $('#log').stop(true, true).fadeOut(500)
          , 5000

    console.log = print

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

      window.onerror = (message, url, line) ->
        console.log "#{message} (#{url}:#{line})"

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
      if message.message
        console.log "error: #{message.message}"
      else
        console.log "error: #{message}"

    excel:
      fillCsv: (csv, callback) ->
        rows = d3.csv.parseRows csv
        new Promise (resolve, reject) ->
          if e2d3.util.isExcel()
            Office.context.document.setSelectedDataAsync rows, coercionType: Office.CoercionType.Matrix, (result) ->
              if result.status == Office.AsyncResultStatus.Succeeded
                resolve null
              else
                reject result.error
          else
            resolve ChartData.fromArray rows

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
              resolve(new Binding(result.value))
            else
              reject(result.error)

      bindCsv: (csv, callback) ->
        new Promise (resolve, reject) ->
          resolve(new DummyBinding ChartData.fromCsv csv)

    data:
      empty: ChartData.empty
      fromCsv: ChartData.fromCsv

    api: api

    util:
      isExcel: () ->
        !!Office.context.document

      urlParam: (name) ->
        results = new RegExp("[\?&]#{name}(=([^&#]*))?").exec(window.location.href);
        if results == null then null else results[2] || 0

  e2d3
