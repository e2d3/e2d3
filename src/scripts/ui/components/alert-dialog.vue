<template lang="jade">
.modal.fade(tabindex='-1')
  .modal-dialog
    .modal-content
      .modal-header
        h5.modal-title {{title}}
      .modal-body {{message}}
      .modal-footer
        button.btn.btn-sm.btn-default(data-dismiss='modal') OK
</template>

<script lang="coffee">
$ = require 'jquery'

module.exports =
  data: () ->
    title: 'title'
    message: 'message'

  methods:
    show: (err) ->
      @title = err.name
      @message = err.message
      $(@$el).modal()
</script>
