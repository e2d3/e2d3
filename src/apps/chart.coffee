params = window.location.hash.substring(1).split '!'

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

require ['bootstrap', 'jquery', 'vue', 'd3', 'e2d3', 'ui/i18n', 'ui/components', 'ui/colorthemes', 'ui/capabilities'], (bootstrap, $, Vue, d3, e2d3, i18n, components, colorthemes, capabilities) ->

  e2d3.util.setupLiveReloadForDelegateMode()

  $ -> $('[data-toggle="tooltip"]').tooltip()

  new Vue
    el: 'body'

    data: () ->
      bound: true
      capabilities: {}
      themes: colorthemes
      selectedColors: []

    components:
      themes:
        props: ['themes']
        template: '#themes'
        methods:
          select: (theme) ->
            @$parent.selectedColors = theme.colors
            @$parent.chart().storage 'colors', theme.colors

    ready: () ->
      @binding = null
      @baseUrl = e2d3.util.baseUrl _path

      @fetchManifest()
      @overrideModulesFromManifest()

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
        chart = e2d3.excel.initAttribute 'chart',
          path: _path
          scriptType: _scriptType
          dataType: _dataType

        parameter = e2d3.excel.initAttribute 'parameter', {}

        @selectedColors = parameter.colors ? @themes[0].colors

      createFrame: () ->
        # Refer from child frame
        # It needs Excel API initialized
        window.storage = (key, value) =>
          parameter = e2d3.excel.getAttribute 'parameter'
          if value?
            parameter[key] = value
            e2d3.excel.storeAttribute 'parameter', parameter
            @storageChanged key, value
          parameter[key]

        @frame = document.createElement 'iframe'
        @frame.src = 'frame.html'
        @frame.width = '100%'
        @frame.height = '100%'
        @frame.frameBorder = 0
        @frame.setAttribute 'data-base-url', @baseUrl
        @frame.setAttribute 'data-script-type', _scriptType
        @frame.setAttribute 'data-data-type', _dataType

        @$els.frame.appendChild @frame

        new Promise (resolve, reject) =>
          checkframe = () =>
            if @chart()?
              resolve()
            else
              setTimeout checkframe, 100
          checkframe()

      storageChanged: (key, value) ->
        if key == 'colors'
          @selectedColors = value

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
          .then () =>
            @bound = true
          .catch (err) =>
            @onError err

      saveImage: (type) ->
        e2d3.save @chart().save().node(), type, @baseUrl

      shareChart: () ->
        @getBoundData()
          .then (data) ->
            parameter = e2d3.excel.getAttribute 'parameter'
            e2d3.api.upload _path, _scriptType, parameter, data
          .then (result) =>
            @showShare result.url
          .catch (err) =>
            @showAlert name: 'Error on sharing', message: err.statusText

      goHome: () ->
        e2d3.excel.removeAttribute 'chart'
        e2d3.excel.removeAttribute 'parameter'
        @binding?.release().catch(@onError)
        window.location.href = 'index.html'

      fetchManifest: () ->
        d3.promise.yaml "#{@baseUrl}/manifest.yml"
          .then (obj) =>
            @capabilities = capabilities.extract obj.capabilities
          .catch (err) =>
            @capabilities = capabilities.extract undefined

      overrideModulesFromManifest: () ->
        d3.promise.yaml "#{@baseUrl}/manifest.yml"
          .then (obj) => console.log(obj.modules)
          .catch (err) => console.log(err)

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
        @showAlert i18n.error err
        e2d3.onError err

      showAlert: (title, message) ->
        @$refs.alert.show title, message

      showShare: (url) ->
        @$refs.share.show url
