define ['params!', 'jquery'], (params, $) ->
  class E2D3Util
    isExcel: () ->
      !!Office.context.document

    isDevelopment: () ->
      $('script[src*="livereload.js"]').length != 0

    isStandalone: () ->
      $('script[src*=":35730/livereload.js"]').length != 0

    isDebugEnabled: () ->
      params.debug? && @isExcel()

    urlParam: (name) ->
      results = new RegExp("[\?&]#{name}(=([^&#]*))?").exec(window.location.search);
      if results == null then null else results[2]

  new E2D3Util()
