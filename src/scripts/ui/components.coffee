define (require, exports, module) ->
  Vue = require 'vue'
  Vue.component 'alert-dialog', require './components/alert-dialog.vue'
  Vue.component 'share-dialog', require './components/share-dialog.vue'
  Vue.component 'theme-label', require './components/theme-label.vue'
  Vue
