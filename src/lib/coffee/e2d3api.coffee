define ['jquery', 'd3', 'd3.promise', 'queue'], ($, d3, d3Promise, queue) ->
  apiBaseUrl = '/api'

  # served from gulp-webserver
  isStandalone = $('script[src*=":35730/livereload.js"]').length != 0

  console.log 'mode: standalone' if isStandalone

  server =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json apiBaseUrl + '/users', (error, json) ->
          reject error if error
          resolve json.charts

  standalone =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.html '/contrib/', (error, html) ->
          reject error if error
          charts = []
          d3.select html
            .selectAll 'a'
            .each (d, i) ->
              chart =
                baseUrl: d3.select(this).attr('href')
                type: 'js'
              charts.push chart
          charts.shift()
          resolve charts

  if isStandalone then standalone else server
