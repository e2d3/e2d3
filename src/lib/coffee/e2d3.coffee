define ['e2d3api', 'e2d3model', 'e2d3excel', 'e2d3util', 'e2d3loader', 'renderer'], (api, model, excel, util, loader, renderer) ->

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

    onError: (message) ->
      if message?.stack?
        console.log JSON.stringify(message), message.stack
      else
        console.log JSON.stringify(message)

    excel: null
    data: empty: () -> new ChartDataTable []
    api: api
    util: util
    save: renderer.save

  e2d3
