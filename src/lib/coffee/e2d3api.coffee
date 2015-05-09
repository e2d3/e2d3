define ['jquery', 'd3'], ($, d3) ->
  apiBaseUrl = '/api'

  # served from gulp-webserver
  mode =
    if sessionStorage.getItem 'delegate'
      'delegate'
    else if document.cookie.indexOf('e2d3_standalone') != -1
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
