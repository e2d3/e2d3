define ['params!', 'jquery', 'd3'], (params, $, d3) ->
  apiBaseUrl = '/api'

  # served from gulp-webserver
  mode =
    if params.delegate?
      'delegate'
    else if $('script[src*=":35730/livereload.js"]').length != 0
      'standalone'
    else
      'server'

  console.info 'mode: ' + mode

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

  delegate =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json 'https://localhost:8443/api/categories/delegate', (error, json) ->
          reject error if error
          resolve json.charts

  switch mode
    when 'delegate' then delegate
    when 'standalone' then standalone
    else server
