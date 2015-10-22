define ['vue', './components/alert.vue', './components/share.vue', './components/theme-label.vue'], (Vue, alert, share, themeLabel) ->
  Vue.component 'alert', alert
  Vue.component 'share', share
  Vue.component 'theme-label', themeLabel
