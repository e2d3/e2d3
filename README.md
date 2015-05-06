Getting Started
====

This page explains about how to set up a developmental environment when you want to add a new chart to E2D3. If you are not a developer, you can install from Apps for Excel.

## Requirements

* Excel 2013 or Excel Online (Not required for development. You can develop charts with MacOSX also.)
* [Node.js](http://nodejs.org/)

##Get the source code
You can clone e2d2/e2d3 from Github and e2d3 refers e2d3/e2d3-contrib as a submodule, so you also have to clone that by --recursive option. The URL below is read only.

```bash
$ git clone https://github.com/e2d3/e2d3.git --recursive
```

If you have commit permission to an E2D3 github repository, you will have to change the origin URL.

```bash
$ cd e2d3
$ git remote set-url origin git@github.com:e2d3/e2d3.git
$ git pull -u origin master
$ cd contrib
$ git remote set-url origin git@github.com:e2d3/e2d3-contrib.git
$ git pull -u origin master
```

## Install

First, you have to install reference libraries.

```
$ npm install
```

By executing this command, you can get libraries necessary for other libraries at build using `npm`. You can also get libraries necessary for front-end using `bower`.

If the installation is successful, `node_modules` directory and `bower_components` directory will be created.


## Run a development server

Now, launch a local development server you can use when you create a chart. By executing `npm start`, you can run the build to launch the server.

```
$ npm start

> e2d3@0.3.0 start /Users/.../src/e2d3
> gulp run

[12:18:27] Requiring external module coffee-script/register
[12:18:28] Using gulpfile ~/src/e2d3/gulpfile.coffee
...
[12:18:29] Webserver started at http://0.0.0.0:8000
```

```
$ git clone https://github.com/e2d3/e2d3-contrib.git
$ cd e2d3-contrib
$ e2d3

[E2D3] Publish /Users/chimera/Sites/e2d3-server/e2d3/contrib
[E2D3] LiveReload server started at lr://0.0.0.0:35730
[E2D3] Webserver started at http://0.0.0.0:8000
[E2D3] Webserver(SSL) started at https://0.0.0.0:8443
```

Then access to [http://localhost:8000/](http://localhost:8000/)

##Develop on browser

After launching a server, you will see some charts when you access [http://localhost:8000/index.html](http://localhost:8000/index.html). These are showing the content of `contrib` directory.

On the development server, Live Reload function of browser is on, so when you update a file, the build will automatically run and browser will be updated.

For example, after accessing "Simple Bar Chart", open `contrib/barchart-javascript/main.js` with an editor and change

```javascript
var height = 300;
```

to 

```javascript
var height = 100;
```

on line 4. When you save the file, you will see the browser updated and the vertical axis getting shorter.

Usually, this is a better way for development.

## Develop and check on Excel2013
In reference to the page below, you have to put manifest file [e2d3.xml](https://github.com/e2d3/e2d3/blob/master/e2d3.xml) in a shared folder and register with Excel2013.

* [JavaScriptで誰でも簡単に作って稼げる「Office用アプリ」とは？](http://www.atmarkit.co.jp/ait/articles/1301/25/news063_3.html)

You can’t refer to a local manifest file on Excel2013, so you have to use a shared folder.
If you run a HTTP server by your personal computer, such as Mac or Linux, you have to change the SourceLocation URL of a manifest file.
By using this manifest file, you can run a program on Visual Studio and this is a better way because you can do a stepwise execution. If you just want to create a chart, you can also do a stepwise execution on Internet Explorer.

Getting Started
====

以下は、E2D3のチャートを新しく追加開発する場合の開発環境のセットアップ方法について説明します。開発者以外が使用する場合はExcelのOffice Storeからインストールしてください。

## 必要なもの

* Excel 2013 - 開発時はブラウザでも可能ですが、最終的な動作確認に必要です
* [Node.js](http://nodejs.org/)


## ソースコードの取得

Githubからe2d3/e2d3をcloneします。e2d3はe2d3/e2d3-contribをサブモジュールとして参照しているので、--recursiveオプションでそれもcloneしてきます。以下でcloneしているURLは読み取り専用です。

```bash
$ git clone https://github.com/e2d3/e2d3.git --recursive
```

E2D3のgithubレポジトリへのコミット権限を持っている場合は、originのURLを変更します。

```bash

$ cd e2d3
$ git remote set-url origin git@github.com:e2d3/e2d3.git
$ git pull -u origin master
$ cd contrib
$ git remote set-url origin git@github.com:e2d3/e2d3-contrib.git
$ git pull -u origin master
```


## 依存ライブラリのインストール

参照しているライブラリをインストールします。

```bash
$ npm install
```

コマンドを実行すると、`npm`を使ってビルド時の依存ライブラリ、および、`bower`を使ってフロントエンドの依存ライブラリが取得されます。

`node_modules`と`bower_components`のディレクトリが出来ていれば成功です。


## 開発用の簡易サーバを立ち上げる

チャートを開発する際に使用する事の出来るローカルの簡易サーバを立ち上げます。`npm start`を実行すると、各種ビルドが走り立ち上がるようになっています。

```bash
$ npm start

> e2d3@0.3.0 start /Users/.../src/e2d3
> gulp run

[12:18:27] Requiring external module coffee-script/register
[12:18:28] Using gulpfile ~/src/e2d3/gulpfile.coffee
...
[12:18:29] Webserver started at http://0.0.0.0:8000
```


## ブラウザで開発する

簡易サーバを立ち上げた後、 [http://localhost:8000/index.html](http://localhost:8000/index.html) にアクセスするといくつかチャートが表示されると思います。これらは`contrib`ディレクトリの内容を表示したものになっています。

簡易サーバではブラウザのLive Reload機能が有効になっており、この状態でファイルを変更すると自動的にビルドが走りブラウザが更新されます。

例えばブラウザで"Simple Bar Chart"のチャートにアクセスしたあと、エディタで`contrib/barchart-javascript/main.js`を開き、4行目の

```javascript
var height = 300;
```

を

```javascript
var height = 100;
```

に変更してください。ファイルを保存すると、開いているブラウザが勝手に更新されチャートの縦幅が縮んでいるのがわかると思います。

普段はこの状態で開発すると良いと思います。


## Excel2013で開発・確認する

下記の記事を参考にマニフェストファイル [e2d3.xml](https://github.com/e2d3/e2d3/blob/master/e2d3.xml) を共有フォルダにおき、Excel2013に登録してください。

* [JavaScriptで誰でも簡単に作って稼げる「Office用アプリ」とは？](http://www.atmarkit.co.jp/ait/articles/1301/25/news063_3.html)

Excel2013からローカルのマニフェストファイルは参照できないようです。かならず共有フォルダを使用してください。

もし、MacやLinux等別マシンでHTTPサーバを動かしている場合は、マニフェストのSourceLocationのURLを変更してください。

このマニフェストを使用して、Visual Studio上から実行することも出来ます。Excelで実行したときにJavascriptのステップ実行等が出来るのでVisual Studioがあると便利ですが、チャートを作るだけであれば、Internet Explorer上でステップ実行しても良いと思います。

