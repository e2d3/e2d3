define ['d3', 'colorbrewer'], (d3, colorbrewer) ->
  colorthemes = []

  do ->
    currentType = null
    for name, theme of colorbrewer
      currentType = 'continuous' if name == 'YlGn'
      currentType = 'highlow' if name == 'PuOr'
      currentType = 'discrete' if name == 'Accent'

      lastColors = (colors for num, colors of theme)[-1..][0]
      colorthemes.push
        name: name
        type: currentType
        colors: lastColors

  colorthemes.push
    name: 'Category10'
    type: 'discrete'
    colors: d3.scale.category10().range()
  colorthemes.push
    name: 'Category20'
    type: 'discrete'
    colors: d3.scale.category20().range()
  colorthemes.push
    name: 'Category20b'
    type: 'discrete'
    colors: d3.scale.category20b().range()
  colorthemes.push
    name: 'Category20c'
    type: 'discrete'
    colors: d3.scale.category20c().range()

  colorthemes.push
    name: 'Campfire'
    type: 'discrete'
    colors: ['#588C7E', '#F2E394', '#F2AE72', '#D96459', '#8C4646']

  colorthemes
