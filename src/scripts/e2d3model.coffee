define ['d3'], (d3) ->

  unenumerable = (obj, name) ->
    desc = Object.getOwnPropertyDescriptor obj, name
    desc.enumerable = false
    Object.defineProperty obj, name, desc

  replaceArrayGeneratorFunctions = (cls) ->
    replaceFunction = (name) ->
      original = cls.prototype[name]
      cls.prototype[name] = () ->
        ret = original.apply this, arguments
        ret.__proto__ = this.__proto__
        ret.header ?= this.header
        ret

    replaceFunction 'concat'
    replaceFunction 'filter'
    replaceFunction 'slice'

  REGEXP_NUMBER = /^[-+]?(\d{1,3}(,?\d{3})*(\.\d+)?|\.\d+)([eE][-+]?\d+)?$/
  REGEXP_ISODATE = /^\d{4}-\d{1,2}-\d{1,2}$/
  REGEXP_YMD = /^\d{4}\/\d{1,2}\/\d{1,2}$/
  REGEXP_MDY = /^\d{1,2}\/\d{1,2}\/\d{4}$/

  PARSE_ISODATE = d3.time.format('%Y-%m-%d').parse
  PARSE_YMD = d3.time.format('%Y/%m/%d').parse
  PARSE_MDY = d3.time.format('%m/%d/%Y').parse

  convert = (value, callback) ->
    if REGEXP_NUMBER.test value
      callback +(value.replace /,/, '')
    else if REGEXP_ISODATE.test value
      callback PARSE_ISODATE value
    else if REGEXP_YMD.test value
      callback PARSE_YMD value
    else if REGEXP_MDY.test value
      callback PARSE_MDY value

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
      rows = @length
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
          values.push value
      values

    convertToNumber: () ->
      for row in @
        for value, i in row
          convert value, (converted) -> row[i] = converted
      @

    ###
    # ChartDataKeyValueListへの変換
    ###
    toList: (options) -> new ChartDataKeyValueList @, options

    ###
    # ChartDataKeyValueMapへの変換
    ###
    toMap: (options) -> new ChartDataKeyValueMap @, options

    ###
    # ChartDataKeyValueNestedへの変換
    ###
    toNested: (options) -> new ChartDataKeyValueNested @, options

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
    constructor: (table, options) ->
      header = options?.header

      if !header?
        header = table[0]
        table = table[1..]

      data = table.map (row) ->
        obj = {}
        for key, i in header
          obj[key] = row[i]
        obj

      @header = header
      @push.apply @, data

      @typing() if options?.typed

    ###
    # 全ての値を返す
    ###
    values: (fields...) ->
      values = []
      for row in @
        for own name, value of row
          continue if fields? && fields.indexOf(name) == -1
          values.push value
      values

    typing: () ->
      for row in @
        for own name, value of row
          convert value, (converted) -> row[name] = converted
      @

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
    constructor: (table, options) ->
      header = options?.header

      if !header?
        header = table[0][1..]
        table = table[1..]

      keys = []
      for row in table
        data = row[1..]
        obj = {}
        for key, i in header
          obj[key] = data[i]
        @[row[0]] = obj
        keys.push row[0]

      @header = header
      @keys = keys
      unenumerable @, 'header'
      unenumerable @, 'keys'

      @typing() if options?.typed

    ###
    # 全ての値を返す
    ###
    values: (fields...) ->
      values = []
      for own key, row of @
        for own name, value of row
          continue if fields? && fields.indexOf(name) == -1
          values.push value
      values

    typing: () ->
      for own key, row of @
        for own name, value of row
          convert value, (converted) -> row[name] = converted
      @

  unenumerable ChartDataKeyValueMap.prototype, 'values'
  unenumerable ChartDataKeyValueMap.prototype, 'typing'

  ###
  # 入れ子構造
  ###
  class Node
    constructor: (@name) ->

    findOrCreateChild: (name) ->
      if !@children?
        @children = []
        unenumerable @, 'children'
      for child in @children
        return child if child.name == name
      newchild = new Node name
      @children.push newchild
      newchild

  unenumerable Node.prototype, 'findOrCreateChild'

  class ChartDataKeyValueNested extends Node
    constructor: (table, options) ->
      name = options?.name ? 'root'
      valueColumnCount = options?.valueColumnCount ? 1
      header = options?.header

      super name

      if !header?
        header = table[0][-valueColumnCount..]
        table = table[1..]
      lastindex = table[0].length - 1

      for row in table
        path = row[0...-valueColumnCount]
        values = row[-valueColumnCount..]

        current = @
        for name in path
          break if !name
          current = current.findOrCreateChild name

        for key, i in header
          if values[i] != ''
            current[key] = values[i]

      @header = header

  replaceArrayGeneratorFunctions ChartDataTable
  replaceArrayGeneratorFunctions ChartDataKeyValueList

  ###
  # exports
  ###
  models =
    ChartDataTable: ChartDataTable
    ChartDataKeyValueList: ChartDataKeyValueList
    ChartDataKeyValueMap: ChartDataKeyValueMap

  models
