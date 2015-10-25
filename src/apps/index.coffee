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
        { id: 'example', label: 'Examples', image: 'gavel' },
        { id: 'hackathon', label: 'Hackathon', image: 'bolt' }
      ]
      charts: []

    computed:
      visibleCharts: () ->
        @charts.filter (chart) =>
          if @selected != 'uncategorized'
            chart.tags? && chart.tags.indexOf(@selected) != -1
          else
            !chart.tags? || chart.tags.length == 0

    components:
      chart:
        data: () ->
          readme: ''
        computed:
          baseUrl: -> e2d3.util.baseUrl(this.path)
          cover: -> @baseUrl + '/thumbnail.png'
          link: -> "chart.html##{@path}!#{@scriptType}!#{@dataType}"
        ready: () ->
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
