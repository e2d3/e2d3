params = window.location.hash.substring(1).split ':'

###
# load parameters
###
_path = params[0] ? '.'
_scriptType = params[1] ? 'js'
_dataType = params[2] ? 'csv'

###
# config
###
require.config
  paths: E2D3_DEFAULT_PATHS
  shim: E2D3_DEFAULT_SHIM
  map: E2D3_DEFAULT_MAP
  config:
    text:
      useXhr: () -> true

require ['bootstrap', 'vue', 'd3', 'e2d3', 'ui/components'], (bootstrap, Vue, d3, e2d3, components) ->

  e2d3.util.setupLiveReloadForDelegateMode()

  new Vue
    el: 'body'

    data: () ->
      bound: true
      themes: [
        { name: 'd3.category10', colors: d3.scale.category10().range() },
        { name: 'd3.category20', colors: d3.scale.category20().range() },
        { name: 'd3.category20b', colors: d3.scale.category20b().range() },
        { name: 'd3.category20c', colors: d3.scale.category20c().range() },
        { name: 'Red', colors: ['#fff', '#f00'] },
        { name: 'Green', colors: ['#fff', '#0f0'] },
        { name: 'Blue', colors: ['#fff', '#00f'] },
        { name: 'Black', colors: ['#fff', '#000'] },
      ]
      selectedColors: []

    components:
      theme:
        methods:
          select: () ->
            @$parent.selectedColors = this.colors
            @$parent.chart().storage 'colors', this.colors

    ready: () ->
      @binding = null
      @baseUrl = e2d3.util.baseUrl _path

      @initExcel()
        .then () =>
          @initState()
          @createFrame()
        .then () =>
          @debug().setupDebugConsole() if e2d3.util.isDebugConsoleEnabled()

          @bindStored()
            .catch (err) =>
              @fillWithSampleData()

    methods:
      initExcel: () ->
        e2d3.initialize()

      initState: () ->
        chart = e2d3.excel.getAttribute 'chart'
        if !chart || !chart.parameters
          chart =
            path: _path
            scriptType: _scriptType
            dataType: _dataType
            parameters: {}
          e2d3.excel.storeAttribute 'chart', chart

        @selectedColors = chart.parameters.colors ? @themes[0].colors

      createFrame: () ->
        # Refer from child frame
        # It needs Excel API initialized
        window.storage = (key, value) ->
          chart = e2d3.excel.getAttribute 'chart'
          if arguments.length == 2
            chart.parameters[key] = value
            e2d3.excel.storeAttribute 'chart', chart
          chart.parameters[key]

        @frame = document.createElement 'iframe'
        @frame.src = 'frame.html'
        @frame.width = '100%'
        @frame.height = '100%'
        @frame.frameBorder = 0
        @frame.setAttribute 'data-base-url', @baseUrl
        @frame.setAttribute 'data-script-type', _scriptType
        @frame.setAttribute 'data-data-type', _dataType

        @$$.frame.appendChild @frame

        new Promise (resolve, reject) =>
          checkframe = () =>
            if @chart()?
              resolve()
            else
              setTimeout checkframe, 100
          checkframe()

      chart: () ->
        @frame?.contentWindow?.chart

      debug: () ->
        @frame?.contentWindow?.debug

      fillWithSampleData: () ->
        @fetchSampleData()
          .then () =>
            @bindSelected()
          .then () =>
            @bound = true
          .catch (err) =>
            @onError err
            @bound = false

      rebindSelectedCells: () ->
        @bindSelected()
          .catch (err) =>
            @onError err

      saveImage: (type) ->
        e2d3.save @chart().save().node(), type, @baseUrl

      shareChart: () ->
        @getBoundData()
          .then (data) ->
            e2d3.api.upload _path, _scriptType, data
          .then (result) =>
            @showShare result.url
          .catch (err) =>
            @showAlert 'Error on sharing', err.statusText ? err

      goHome: () ->
        e2d3.excel.removeAttribute 'chart'
        @binding?.release().catch(@onError)
        window.location.href = 'index.html'

      fetchSampleData: () ->
        d3.promise.text "#{@baseUrl}/data.#{_dataType}"
          .then (text) ->
            e2d3.excel.fill _dataType, text

      bindSelected: () ->
        @bind e2d3.excel.bindSelected()

      bindStored: () ->
        @bind e2d3.excel.bindStored()

      bind: (binder) ->
        updateBinding = (binding) =>
          @binding?.release().catch(@onError)
          @binding = binding
          @binding.on 'change', renderBinding

        renderBinding = () =>
          @getBoundData()
            .then (data) =>
              @chart().update data
              Promise.resolve()

        binder
          .then (binding) ->
            updateBinding(binding)
            renderBinding()

      getBoundData: () ->
        if @binding?
          @binding.fetchData()
        else
          Promise.resolve(e2d3.data.empty())

      onError: (err) ->
        @showAlert err.name, err.message if err.code?
        e2d3.onError err

      showAlert: (title, message) ->
        @$.alert.show title, message

      showShare: (url) ->
        @$.share.show url
