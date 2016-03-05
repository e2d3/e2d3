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

require ['bootstrap', 'jquery', 'vue', 'd3', 'marked', 'e2d3', 'ui/secret'], (bootstrap, $, Vue, d3, marked, e2d3, secret) ->

  e2d3.restoreChart()

  secret () ->
    $('#delegate').show()

  if e2d3.util.isDelegateMode()
    $('#delegate a').html('<i class="fa fa-sign-out"></i> Leave from delegate mode')
    $('#delegate').show()

  $('#delegate').on 'click', (e) ->
    e2d3.util.toggleDelegateMode()
    window.location.reload()

  new Vue
    el: 'body'
    data:
      selected: (sessionStorage.getItem 'selected') ? 'recommended'
      tags: [
        { id: 'recommended', label: 'Recommended', image: 'star' },
        { id: 'statistics', label: 'Statistics', image: 'balance-scale' },
        { id: 'example', label: 'Examples', image: 'gavel' },
        { id: 'hackathon', label: 'Hackathon', image: 'bolt' },
        { id: 'map', label: 'Map', image: 'map-marker' },
        { id: 'marathon', label: 'Marathon', image: 'map' },
        { id: 'tbd', label: 'To Be Developed', image: 'bomb' },
      ]
      charts: []

    computed:
      selectedCharts: () ->
        @charts.filter (chart) =>
          if @selected != 'uncategorized'
            chart.tags? && chart.tags.indexOf(@selected) != -1
          else
            !chart.tags? || chart.tags.length == 0

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
