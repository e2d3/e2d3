define ['vue', './components/alert-dialog.vue', './components/share-dialog.vue', './components/theme-label.vue'], (Vue, alertDialog, shareDialog, themeLabel) ->
  Vue.component 'alert-dialog', alertDialog
  Vue.component 'share-dialog', shareDialog
  Vue.component 'theme-label', themeLabel
