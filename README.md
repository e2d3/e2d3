E2D3
====

E2D3 is JavaScript library for using D3.js on Excel.

[![license](https://img.shields.io/badge/license-Apache%202-blue.svg?style=flat)](LICENSE)

## Requirements

* Excel 2013 (Not required for development. You can develop charts with MacOSX also.)
* [Node.js](http://nodejs.org/)

## Install

```shell
$ git clone https://github.com/e2d3/e2d3.git --recursive
$ cd e2d3
$ npm install
```

## Run Development Server

```
$ cd e2d3
$ npm start

> e2d3@0.3.0 start /Users/.../src/e2d3
> gulp run

[12:18:27] Requiring external module coffee-script/register
[12:18:28] Using gulpfile ~/src/e2d3/gulpfile.coffee
...
[12:18:29] Webserver started at http://0.0.0.0:8000
```

Then access to [http://localhost:8000/index.html](http://localhost:8000/index.html)

## Run E2D3 on Excel 2013

下記記事を参考にマニフェストファイル"[e2d3.xml](e2d3.xml)"を共有フォルダに配置して、Excel 2013に登録してください。

[JavaScriptで誰でも簡単に作って稼げる「Office用アプリ」とは？](http://www.atmarkit.co.jp/ait/articles/1301/25/news063_3.html)

もしMacやLinux等別マシンでHTTPサーバを動かしている場合は、マニフェストのSourceLocationのURLを変更してください。

このマニフェストを使用して、Visual Studio上から実行することも出来ます。
Excelで実行したときにJavascriptのステップ実行等が出来るのでVisual Studioがあると便利ですが、
チャートを作るだけであれば、Internet Explorer上でステップ実行しても良いと思います。


## How to add charts

./contrib に新しくディレクトリを作り下記ファイルを配置します。
contribは、[e2d3/e2d3-contrib](https://github.com/e2d3/e2d3-contrib) として管理されている別レポジトリです。


```
.
+-- LICENSE
+-- README.md
+-- thumbnail.png
+-- main.{js,coffee,jsx}
+-- data.{csv,tsv}
```

### LICENSE

ライセンスファイル。可能な限りチャートのライセンスを明示してください。

### README.md

チャートの紹介文、使い方及びデータフォーマットを記述してください。
Excelやブラウザ上でもこのファイルが表示されます。

### thumbnail.png

一覧に表示されるサムネイル画像です。

### main.{js,coffee,jsx}

E2D3のシステム側から最初に呼び出されるファイルです。
[AMD形式](https://github.com/amdjs/amdjs-api/wiki/AMD)で記述する必要があります。
詳細についてはWiki(制作中)を参照してください。

CoffeescriptおよびJSX(JavaScript syntax extension for React)は実験的サポートです。

### data.{csv,tsv}

main.jsを使って表示可能なサンプルデータを置いてください。
Excelではサンプルデータ投入ボタンを押すと読み込まれます。
ブラウザ上で開発する際には、チャートの画面に飛ぶと表示時にすぐに読み込まれます。

## License
[Apache License 2.0](LICENSE)
