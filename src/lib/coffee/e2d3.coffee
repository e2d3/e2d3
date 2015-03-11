define ['params!', 'd3', 'jquery', 'e2d3api', 'e2d3model', 'e2d3excel', 'e2d3util', 'e2d3loader'], (params, d3, $, api, model, excel, util, loader) ->

  ###*
  # if '?debug' parameter is specified
  # change `console.log()`'s output to popup dialog
  ###
  setConsoleToPopup = () ->
    return if !util.isDebugEnabled()

    $('#log').on 'click', () ->
      clearTimeout $('#log').data 'timer'
      $('#log').stop(true, true).fadeOut(100)

    print = (msg) ->
      return if (msg + '').indexOf('Agave.HostCall.') == 0

      $('#log').append($('<div>').text(JSON.stringify(msg)))

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

  e2d3 =
    initialize: () ->
      setConsoleToPopup()

      new Promise (resolve, reject) ->
        # 1秒待っても初期化されなければExcelではないとみなす
        timer = setTimeout () ->
          console.log 'initialized: browser'
          e2d3.excel = excel.initialize()
          resolve Office.InitializationReason.Inserted
        , 1000

        Office.initialize = (reason) ->
          clearTimeout timer
          console.log 'initialized: excel'
          e2d3.excel = excel.initialize()
          resolve reason

    onError: (message) ->
      if message?.stack?
        console.log message, message.stack
      else
        console.log message

    excel: null
    data: empty: () -> new ChartDataTable []
    api: api
    util: util

  e2d3
