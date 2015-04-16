define ['jquery', 'd3', 'queue'], ($, d3, queue) ->
  apiBaseUrl = '/api'

  # served from gulp-webserver
  isStandalone = $('script[src*=":35730/livereload.js"]').length != 0

  console.info 'mode: standalone' if isStandalone

  server =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json apiBaseUrl + '/categories/github/e2d3/e2d3-contrib', (error, json) ->
          reject error if error
          resolve json.charts

  standalone =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json apiBaseUrl + '/categories/develop', (error, json) ->
          reject error if error
          resolve json.charts

  if isStandalone then standalone else server
