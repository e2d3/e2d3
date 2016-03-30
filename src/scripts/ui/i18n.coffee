define ['vue', 'vue-i18n'], (Vue, i18n) ->
  locales =
    en:
      visualize: 'Visualize'
      linkdata: 'Reset data area'
      retryfilling: 'Retry filling sample data'
      sharechart: 'Share chart'
      saveimage: 'Save image'
      saveassvg: 'Save as SVG'
      saveaspng: 'Save as PNG'
    ja:
      visualize: '可視化する'
      linkdata: 'データ範囲を再設定する'
      retryfilling: 'サンプルデータを挿入する'
      sharechart: 'シェアする'
      saveimage: '画像を保存する'
      saveassvg: 'SVGとして保存'
      saveaspng: 'PNGとして保存'

  lang = switch Office?.context?.displayLanguage ? navigator.languages?[0] ? navigator.language ? navigator.browserLanguage
    when 'ja-JP' then 'ja'
    when 'ja-jp' then 'ja'
    when 'ja' then 'ja'
    else 'en'

  Vue.use i18n,
    lang: lang
    locales: locales
