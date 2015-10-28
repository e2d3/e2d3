define ['d3', 'js-yaml'], (d3, yaml) ->
  d3.yaml = (url, callback) ->
    d3.text url, 'application/x-yaml', (error, text) ->
      return callback(error) if error
      callback(null, yaml.safeLoad text)

  d3.promise = do ->
    promisify = (caller, fn) ->
      () ->
        args = Array.prototype.slice.call(arguments)
        new Promise (resolve, reject) ->
          callback = (error, data) ->
            return reject Error(error) if error
            resolve data
          fn.apply(caller, args.concat(callback))

    promisified = {}
    ['csv', 'tsv', 'json', 'xml', 'text', 'html', 'yaml'].forEach (fnName) ->
      promisified[fnName] = promisify(d3, d3[fnName])
    promisified

  d3
