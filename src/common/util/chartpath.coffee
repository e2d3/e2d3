if typeof exports == 'object' && typeof exports.nodeName != 'string' && typeof define != 'function'
  global.define = (factory) ->
    factory(require, exports, module)

define (require, exports, module) ->
  config = require 'config'

  exports.encode = (baseUrl) ->
    if ret = baseUrl.match new RegExp('/github/e2d3/e2d3-contrib/contents/([^/]+)$')
      "#{ret[1]}"
    else if ret = baseUrl.match new RegExp('/github/([^/]+)/([^/]+)/contents$')
      "#{ret[1]}/#{ret[2]}"
    else if ret = baseUrl.match new RegExp('/github/([^/]+)/([^/]+)/contents/([^/]+)$')
      "#{ret[1]}/#{ret[2]}/#{ret[3]}"
    else if ret = baseUrl.match new RegExp('/gists/([^/]+)$')
      "gist:#{ret[1]}"
    else if ret = baseUrl.match new RegExp('/local/([^/]+)$')
      "local:#{ret[1]}"
    else
      baseUrl

  exports.decode = (path) ->
    if ret = path.match new RegExp('^local:([^/]+)$')
      "/files/local/#{ret[1]}"
    else if ret = path.match new RegExp('^gist:([^/]+)$')
      "/files/gists/#{ret[1]}"
    else if path.indexOf '://' == -1
      splitted = path.split('/')
      switch splitted.length
        when 1 then "/files/github/e2d3/e2d3-contrib/contents/#{splitted[0]}"
        when 2 then "/files/github/#{splitted[0]}/#{splitted[1]}/contents"
        when 3 then "/files/github/#{splitted[0]}/#{splitted[1]}/contents/#{splitted[2]}"
        else path
    else
      path

  return if !config?.apiBase?

  exports.decodeWithBase = (path) ->
    decoded = exports.decode path
    if ret = decoded.match new RegExp('^/files/')
      "#{config.apiBase}#{decoded}"
    else
      path
