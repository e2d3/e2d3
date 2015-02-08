define ['d3'], (d3) ->
  ###
  # 単純な2次元配列
  ###
  class ChartDataTable extends Array
    constructor: (array) ->
      @.push.apply @, array

    ###
    # 行列の入れ替え
    ###
    transpose: () ->
      cols = d3.max(@, (row) -> row.length)
      rows = @.length
      newarray = []
      for c in [0..cols-1]
        newarray[c] = []
        for r in [0..rows-1]
          newarray[c][r] = @[r][c]
      new ChartDataTable newarray

    ###
    # 全ての値を返す
    ###
    values: () ->
      values = []
      for row in @
        for value in row
          values.push +value if $.isNumeric value
      values

    ###
    # ChartDataKeyValueListへの変換
    ###
    toList: (head) ->
      new ChartDataKeyValueList @, head

    ###
    # ChartDataKeyValueMapへの変換
    ###
    toMap: () ->
      new ChartDataKeyValueMap @

  ###
  # 行毎のヘッダと値のマップ
  #
  # 元データ:
  # a,b,c,d
  # 1,2,3,4
  # 5,6,7,8
  #
  # 出力:
  # [
  #   { a:1, b:2, c:3, d:4 },
  #   { a:5, b:6, c:7, d:8 }
  # ]
  ###
  class ChartDataKeyValueList extends Array
    constructor: (table, head) ->
      if !head
        head = table[0]
        table = table.slice(1)
      data = table.map (row) ->
        obj = {}
        for key, i in head
          obj[key] = row[i]
        obj
      @head = head
      @.push.apply @, data

    ###
    # 全ての値を返す
    ###
    values: () ->
      values = []
      for row in @
        for name, value of row
          values.push +value if $.isNumeric value
      values

  ###
  # 行毎のヘッダと値のマップ
  #
  # 元データ:
  # _,a,b,c
  # x,1,2,3
  # y,4,5,6
  #
  # 出力:
  # {
  #   x: { a:1, b:2, c:3 },
  #   y: { a:4, b:5, c:6 }
  # }
  ###
  class ChartDataKeyValueMap
    constructor: (table) ->
      head = table[0].slice(1)
      for row in table.slice(1)
        data = row.slice(1)
        obj = {}
        for key, i in head
          obj[key] = data[i]
        @[row[0]] = obj

    ###
    # 全ての値を返す
    ###
    values: () ->
      values = []
      for own key, row of @
        for own name, value of row
          values.push +value if $.isNumeric(value)
      values

  ###
  # exports
  ###
  models =
    ChartDataTable: ChartDataTable
    ChartDataKeyValueList: ChartDataKeyValueList
    ChartDataKeyValueMap: ChartDataKeyValueMap

  models
