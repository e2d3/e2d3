define ['vue', 'vue-i18n'], (Vue, i18n) ->
  locales =
    en:
      visualize: 'Visualize'
      linkData: 'Reset data area'
      retryFilling: 'Retry filling sample data'
      selectColorTheme: 'Select color theme'
      shareChart: 'Share chart'
      saveImage: 'Save image'
      saveAsSvg: 'Save as SVG'
      saveAsPng: 'Save as PNG'
      error:
        2003: 'Could not override data because another data already exists in the selected cells.'
    ja:
      visualize: '可視化する'
      linkData: 'データ範囲を再設定する'
      retryFilling: 'サンプルデータを挿入する'
      selectColorTheme: '色を選択'
      shareChart: 'シェアする'
      saveImage: '画像を保存'
      saveAsSvg: 'SVGとして保存'
      saveAsPng: 'PNGとして保存'
      error:
        2003: '既にセルにデータが存在するためデータを書き込めませんでした。'

  lang = switch Office?.context?.displayLanguage ? navigator.languages?[0] ? navigator.language ? navigator.browserLanguage
    when 'ja-JP' then 'ja'
    when 'ja-jp' then 'ja'
    when 'ja' then 'ja'
    else 'en'

  Vue.use i18n,
    lang: lang
    locales: locales

  error: (err) ->
    name: err.name, message: locales[lang]['error'][err.code] ? err.message
