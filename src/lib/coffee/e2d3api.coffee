define ['jquery', 'underscore', 'd3', 'queue'], ($, _, d3, queue) ->
  apiBaseUrl = '/api'

  # served from gulp-webserver
  isStandalone = $('script[src*=":35730/livereload.js"]').length != 0

  console.log 'mode: standalone' if isStandalone

  server =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.json apiBaseUrl + '/categories/github/e2d3/e2d3-contrib', (error, json) ->
          reject error if error
          resolve json.charts

  standalone =
    topcharts: () ->
      new Promise (resolve, reject) ->
        d3.html '/contrib/', (error, html) ->
          reject error if error

          baseUrls = $(html).find('a').map(() -> $(this).attr('href')).filter((i) -> i != 0).get()

          q = queue()

          for baseUrl in baseUrls
            q = q.defer d3.html, baseUrl

          q.await () ->
            error = arguments[0]
            htmls = [].slice.call arguments, 1

            charts = []
            for html, i in htmls
              files = $(html).find('a').map(() -> $(this).attr('href')).filter((i) -> i != 0).get()

              exts = _(files)
                .map (file) ->
                  result = /([^/\.]+)\.([^/\.]+)$/.exec file
                  if result then [result[1], result[2]] else null
                .filter (name) -> name != null
                .map (file) -> file

              extmap = _.object(exts)

              charts.push
                title: baseUrls[i].replace /^\/contrib/, 'e2d3'
                baseUrl: baseUrls[i]
                scriptType: extmap['main']
                dataType: extmap['data']

            resolve charts

  if isStandalone then standalone else server
