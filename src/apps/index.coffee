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

require ['bootstrap', 'jquery', 'vue', 'd3', 'marked', 'e2d3', 'ui/i18n', 'ui/secret'], (bootstrap, $, Vue, d3, marked, e2d3, i18n, secret) ->

  e2d3.restoreChart()

  secret () ->
    $('#delegate').show()

  if e2d3.util.isDelegateMode()
    $('#delegate a').html('<i class="fa fa-sign-out"></i> Leave from delegate mode')
    $('#delegate').show()

  $('#delegate').on 'click', (e) ->
    e2d3.util.toggleDelegateMode()
    window.location.reload()
  Vue.config.debug = true
  new Vue
    el: 'body'
    data:
      selected: (sessionStorage.getItem 'selected') ? 'recommended'
      tags: [
        { id: 'recommended', label: 'Recommended', image: 'star' },
        { id: 'statistics', label: 'Statistics', image: 'balance-scale' },
        { id: 'example', label: 'Examples', image: 'gavel' },
        { id: 'hackathon', label: 'Hackathon', image: 'bolt' },
        { id: 'kurashiki', label: 'Kurashiki', image: 'street-view' },
        { id: 'map', label: 'Map', image: 'map-marker' },
        { id: 'marathon', label: 'Marathon', image: 'map' },
        { id: 'tbd', label: 'To Be Developed', image: 'bomb' },
      ]
      charts: []

    computed:
      selectedCharts: () ->
        @charts
          .filter (chart) =>
            if @selected != 'uncategorized'
              chart.tags.map((t) -> t.name).indexOf(@selected) != -1
            else
              chart.tags.length == 0
          .sort (c1, c2) =>
            if @selected != 'uncategorized'
              order = (chart) => chart.tags.filter((t) => t.name == @selected)[0].order
              order(c1) - order(c2)
            else
              0

    components:
      chart:
        template: '#chart'
        props: ['chart']
        data: ->
          readme: ''
        computed:
          baseUrl: -> e2d3.util.baseUrl(@chart.path)
          link: -> "chart.html##{@chart.path}!#{@chart.scriptType}!#{@chart.dataType}"
          coverBackground: -> 'background-image': 'url(' + @baseUrl + '/thumbnail.png' + ')'
        ready: ->
          d3.text @baseUrl + '/README.md', (error, readme) =>
            @readme = marked readme

    ready: ->
      e2d3.api.topcharts()
        .then (charts) =>
          hasUncategorized = charts.some (chart) -> !chart.tags? || chart.tags.length == 0
          if hasUncategorized
            @tags.push { id: 'uncategorized', label: 'Uncategorized', image: 'question' }
          @charts = charts

    methods:
      select: (id) ->
        @selected = id
        sessionStorage.setItem 'selected', id
