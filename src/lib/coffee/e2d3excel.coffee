define ['d3', 'e2d3model', 'e2d3util'], (d3, model, util) ->
  ChartDataTable = model.ChartDataTable

  ###
  # Excel API
  ###
  class Binding
    constructor: (@binding) ->

    on: (event, handler) ->
      if event == 'change'
        @binding.addHandlerAsync Office.EventType.BindingDataChanged, handler

    fetchData: () ->
      new Promise (resolve, reject) =>
        @binding.getDataAsync valueFormat: Office.ValueFormat.Formatted, (result) ->
          if result.status == Office.AsyncResultStatus.Succeeded
            resolve new ChartDataTable result.value
          else
            resolve new ChartDataTable []

    release: () ->
      new Promise (resolve, reject) =>
        Office.context.document.bindings.releaseByIdAsync @binding.id, (result) =>
          if result.status == Office.AsyncResultStatus.Succeeded
            delete @binding
            resolve()
          else
            reject result.error

  class ExcelAPI
    fill: (type, text) ->
      new Promise (resolve, reject) ->
        rows = d3[type].parseRows text

        Office.context.document.setSelectedDataAsync rows, coercionType: Office.CoercionType.Matrix, (result) ->
          if result.status == Office.AsyncResultStatus.Succeeded
            resolve()
          else
            reject result.error

    bindSelected: () ->
      new Promise (resolve, reject) ->
        Office.context.document.bindings.addFromSelectionAsync Office.BindingType.Matrix, (result) ->
          if result.status == Office.AsyncResultStatus.Succeeded
            resolve new Binding result.value
          else
            reject result.error

    bindPrompt: () ->
      new Promise (resolve, reject) ->
        Office.context.document.bindings.addFromPromptAsync Office.BindingType.Matrix, (result) ->
          if result.status == Office.AsyncResultStatus.Succeeded
            resolve new Binding result.value
          else
            reject result.error

    bindStored: () ->
      new Promise (resolve, reject) ->
        Office.context.document.bindings.getAllAsync (result) ->
          if result.status == Office.AsyncResultStatus.Succeeded
            console.log result.value
            if result.value[0]?
              resolve new Binding result.value[0]
            else
              reject()
          else
            reject result.error

    getAttribute: (key) ->
      Office.context.document.settings.get key

    storeAttribute: (key, value) ->
      Office.context.document.settings.set key, value
      Office.context.document.settings.saveAsync (result) ->
        if result.status == Office.AsyncResultStatus.Succeeded
          console.info 'Settings saved.'
        else
          console.error result.error

    removeAttribute: (key, value) ->
      Office.context.document.settings.remove key
      Office.context.document.settings.saveAsync (result) ->
        if result.status == Office.AsyncResultStatus.Succeeded
          console.info 'Settings saved.'
        else
          console.error result.error

  ###
  # Dummy API
  ###
  class DummyBinding
    constructor: (@data) ->

    on: (event, handler) ->

    fetchData: () ->
      new Promise (resolve, reject) =>
        resolve new ChartDataTable @data

    release: () ->
      new Promise (resolve, reject) ->
        resolve()

  class DummyExcelAPI
    fill: (type, text) ->
      new Promise (resolve, reject) ->
        @rows = d3[type].parseRows text
        resolve()

    bindSelected: () ->
      new Promise (resolve, reject) ->
        resolve new DummyBinding @rows

    bindStored: () ->
      new Promise (resolve, reject) ->
        reject()

    getAttribute: (key) ->
      JSON.parse localStorage.getItem key

    storeAttribute: (key, value) ->
      localStorage.setItem key, JSON.stringify value

    removeAttribute: (key, value) ->
      localStorage.removeItem key

  ###
  # export
  ###
  initialize: () ->
    if util.isExcel()
      new ExcelAPI()
    else
      new DummyExcelAPI()
