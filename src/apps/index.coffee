require ['bootstrap', 'd3', 'd3.promise', 'e2d3', 'markdown'], (bootstrap, d3, d3Promise, e2d3, markdown) ->
  Promise.all [d3.promise.html('cell.html'), e2d3.api.topcharts()]
    .then (values) ->
      cell = values[0]
      charts = values[1]

      figures = d3.select '#contrib'
        .selectAll 'div'
          .data charts
        .enter().append 'div'
          .classed 'col-xs-4 col-sm-3', true
          .each (d, i) ->
            newcell = d3.select(cell.cloneNode(true))

            newcell.select 'img'
              .attr 'src', d.baseUrl + '/thumbnail.png'

            newcell.select '.readme'
              .each ->
                d3.text d.baseUrl + '/README.md', (error, readme) =>
                  this.innerHTML = markdown.toHTML readme, "Maruku"

            newcell.select '.use'
              .attr 'href', "chart.html##{d.baseUrl},#{d.scriptType},#{d.dataType}"

            this.appendChild(newcell.node())

      undefined # cofeescript promise idiom
    .catch (err) ->
      e2d3.onError err
