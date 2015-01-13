define ['d3', 'jquery', 'e2d3api'], (d3, $, api) ->
  class ChartDataTable extends Array
    constructor: (array) ->
      @.push.apply @, array

    transpose: () ->
      cols = d3.max(@, (row) -> row.length)
      rows = @.length
      newarray = []
      for c in [0..cols-1]
        newarray[c] = []
        for r in [0..rows-1]
          newarray[c][r] = @[r][c]
      new ChartDataTable newarray

    values: () ->
      values = []
      for row in @
        for value in row
          values.push +value if $.isNumeric value
      values

    toList: (head) ->
      new ChartDataKeyValueList @, head

    toMap: () ->
      new ChartDataKeyValueMap @

  class ChartDataKeyValueList extends Array
    constructor: (table, head) ->
      if !head
        head = table[0]
        table = table.slice(1)
      data = table.map (row) ->
        obj = {}
        for key, i in head
          obj[key] = row[i]
        obj
      @head = head
      @.push.apply @, data

    values: () ->
      values = []
      for row in @
        for name, value of row
          values.push +value if $.isNumeric value
      values

  class ChartDataKeyValueMap
    constructor: (table) ->
      head = table[0].slice(1)
      for row in table.slice(1)
        data = row.slice(1)
        obj = {}
        for key, i in head
          obj[key] = data[i]
        @[row[0]] = obj

    values: () ->
      values = []
      for own key, row of @
        for own name, value of row
          values.push +value if $.isNumeric(value)
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
          callback new ChartDataTable result.value
        else
          callback new ChartDataTable []

  class DummyBinding
    _data = null

    constructor: (data) ->
      _data = data

    on: (event, handler) ->

    fetchData: (callback) ->
      callback new ChartDataTable _data

  ###*
  # if '?debug' parameter is specified
  # change `console.log()`'s output to popup dialog
  ###
  setConsoleToPopup = () ->
    return if (e2d3.util.urlParam 'debug') == null

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
      if message.message
        console.log "error: #{message.message}"
      else
        console.log "error: #{message}"

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

      urlParam: (name) ->
        results = new RegExp("[\?&]#{name}(=([^&#]*))?").exec(window.location.search);
        if results == null then null else results[2]

  e2d3
