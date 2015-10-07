define ['d3'], (d3) ->
  apiBaseUrl = '/api'

  mode =
    if sessionStorage.getItem 'delegate'
      'delegate'
    else if document.cookie.indexOf('e2d3_standalone') != -1
      'standalone'
    else
      'server'

  console.info '[E2D3] mode: ' + mode

  server =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json apiBaseUrl + '/categories/github/e2d3/e2d3-contrib', (error, json) ->
          reject error if error
          resolve json.charts
    upload: (path, scriptType, data) ->
      new Promise (resolve, reject) ->
        tsv = data.map((row) -> row.join('\t')).join('\n')
        upload =
          chart:
            path: path
            scriptType: scriptType
          data: tsv
        d3.json apiBaseUrl + '/shares'
          .header 'Content-Type', 'application/json'
          .post JSON.stringify(upload), (error, json) ->
            reject error if error
            resolve json

  standalone =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json apiBaseUrl + '/categories/develop', (error, json) ->
          reject error if error
          resolve json.charts
    upload: () ->
      Promise.reject 'Not supported'

  delegate =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json 'https://localhost:8443/api/categories/delegate', (error, json) ->
          reject error if error
          resolve json.charts
    upload: () ->
      Promise.reject 'Not supported'

  switch mode
    when 'delegate' then delegate
    when 'standalone' then standalone
    else server
