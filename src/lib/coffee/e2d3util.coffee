define ['jquery', 'util/chartpath'], ($, chartpath) ->
  # this works only on top frame
  isNativeExcel =
    try
      window.external.GetContext()?
    catch err
      false

  isOffice365Excel =
    window.parent != window

  class E2D3Util
    isExcel: () ->
      isNativeExcel || isOffice365Excel

    isDelegateMode: () ->
      !!(sessionStorage.getItem('delegate'))

    toggleDelegateMode: (value) ->
      if !@isDelegateMode()
        sessionStorage.setItem 'delegate', true
      else
        sessionStorage.removeItem 'delegate'

    setupLiveReloadForDelegateMode: () ->
      if @isExcel() && @isDelegateMode()
        $.getScript 'https://localhost:8443/livereload.js?snipver=1'

    isDebugConsoleEnabled: () ->
      isNativeExcel && @isDelegateMode()

    baseUrl: (path) ->
      chartpath.decode path

    ###*
    # change `console.log()`'s output to popup dialog
    ###
    setupDebugConsole: () ->
      $('#log').on 'click', () ->
        clearTimeout $('#log').data 'timer'
        $('#log').stop(true, true).fadeOut(100)

      print = (msg) ->
        return if (msg + '').indexOf('Agave.HostCall.') == 0

        $('#log').append($('<div>').text(JSON.stringify(msg)))

        # you can't use `$.delay()`
        # http://stackoverflow.com/questions/3329197/jquery-delay-or-timeout-with-stop
        clearTimeout($('#log').data('timer'))
        $('#log').stop(true, true)
          .fadeIn 100, () ->
            $('#log').get(0).scrollTop = $('#log').get(0).scrollHeight
            $('#log').data 'timer', setTimeout () ->
              $('#log').stop(true, true).fadeOut(500)
            , 5000

      window.onerror = (message, url, line) ->
        print "#{message} (#{url}:#{line})"

      console.log = print
      console.info = print
      console.error = print

  new E2D3Util()
