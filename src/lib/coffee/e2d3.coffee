define ['params!', 'd3', 'jquery', 'e2d3api', 'e2d3model', 'e2d3excel', 'e2d3util', 'e2d3loader'], (params, d3, $, api, model, excel, util, loader) ->

  ###
  # export
  ###

  e2d3 =
    initialize: () ->
      new Promise (resolve, reject) ->
        initExcel = () ->
          Office.initialize = (reason) ->
            console.info 'initialized: excel'
            e2d3.excel = excel.initialize()
            resolve reason

        initBrowser = () ->
          console.info 'initialized: browser'
          e2d3.excel = excel.initialize()
          resolve 'inserted'

        if util.isExcel()
          initExcel()
        else
          initBrowser()
      .then (reason) ->
        Promise.resolve(reason)

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
