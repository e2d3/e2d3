<template lang="jade">
.modal.fade(tabindex='-1', role='dialog', aria-labelledby='e2d3-alert', aria-hidden='true')
  .modal-dialog
    .modal-content
      .modal-header
        h5.modal-title {{title}}
      .modal-body {{message}}
      .modal-footer
        button.btn.btn-sm.btn-default(type='button', data-dismiss='modal') OK
</template>

<script lang="coffee">
$ = require 'jquery'

module.exports =
  data: () ->
    title: 'title'
    message: 'message'

  methods:
    show: (title, message) ->
      @title = title
      @message = message
      $(@$el).modal()
</script>
