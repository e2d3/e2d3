require ['bootstrap', 'jquery', 'd3', 'd3.promise', 'e2d3', 'ui/secret', 'markdown'], (bootstrap, $, d3, d3Promise, e2d3, secret, markdown) ->

  secret () ->
    $('#delegate').show()

  if e2d3.util.isDelegateMode()
    $('#delegate a').html('<i class="fa fa-sign-out"></i> Leave from delegate mode')
    $('#delegate').show()

  $('#delegate').on 'click', (e) ->
    e2d3.util.toggleDelegateMode()
    window.location.reload()

  cell = null
  charts = null
  tag = (sessionStorage.getItem 'tag') ? 'recommended'

  updateTag = () ->
    $('.sidebar-item').removeClass 'active'
    $(".sidebar-item[data-label='#{tag}']").addClass 'active'

  updateTag()

  $('.sidebar-item').on 'click', (e) ->
    $this = $(this)

    tag = $this.data 'label'
    sessionStorage.setItem 'tag', tag

    updateTag()

    d3.select '#contrib'
      .selectAll 'div'
      .remove()
    setupGrid()

  e2d3.initialize()
    .then () ->
      chart = e2d3.excel.getAttribute 'chart'
      if chart
        window.location.href = "chart.html##{chart.path},#{chart.scriptType},#{chart.dataType}"

  Promise.all [d3.promise.html('cell.html'), e2d3.api.topcharts()]
    .then (values) ->
      cell = values[0]
      charts = values[1]
      setupGrid()

      hasUncategorized = charts.some (chart) ->
        !chart.tags? || chart.tags.length == 0
      $('#uncategorized').show() if hasUncategorized
      undefined # cofeescript promise idiom
    .catch (err) ->
      e2d3.onError err

  setupGrid = () ->
    d3.select '#contrib'
      .selectAll 'div'
        .data charts.filter (chart) ->
          if tag != 'uncategorized'
            chart.tags? && chart.tags.indexOf(tag) != -1
          else
            !chart.tags? || chart.tags.length == 0
      .enter().append 'div'
        .classed 'col-xs-4', true
        .each (d, i) ->
          newcell = d3.select(cell.cloneNode(true))

          baseUrl = e2d3.util.baseUrl d.path

          newcell.select '.cover'
            .style 'background-image', "url('#{baseUrl}/thumbnail.png')"
            .select '.title'
            .text d.title

          newcell.select '.readme'
            .each ->
              d3.text baseUrl + '/README.md', (error, readme) =>
                this.innerHTML = markdown.toHTML readme, 'Maruku'

          newcell.select '.use'
            .attr 'href', "chart.html##{d.path},#{d.scriptType},#{d.dataType}"

          this.appendChild(newcell.node())
