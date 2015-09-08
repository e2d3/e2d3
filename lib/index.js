'use strict';

var express = require('express');
var path = require('path');
var open = require('open');
var logger = require('morgan');
var cors = require('cors');
var bodyParser = require('body-parser');
var connectLivereload = require('connect-livereload');
var tinylr = require('tiny-lr');
var fs = require('fs');
var http = require('http');
var https = require('https');
var colors = require('colors');

module.exports = function (options) {
  var app = express();

  app.use(logger('dev'));
  app.use(cors());

  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: false }));

  app.use(function (req, res, next) {
    res.cookie('e2d3_standalone', 'true', { maxAge: 10000 });
    next();
  });

  if (options.livereload === -1) {
    app.use(connectLivereload({ src: '/livereload.js?snipver=1' }));
  } else if (options.livereload > 0) {
    app.use(tinylr.middleware({ app: app }));
    app.use(connectLivereload({ port: options.livereload }));
  }

  var api = function (apiBaseUrl) {
    return function (req, res) {
      var createData = function (name) {
        var scriptType = 'js';
        var dataType = 'tsv';

        fs.readdirSync(path.join(options.contrib, name)).forEach(function (child) {
          var match = null;
          if ((match = child.match(/^main\.(js|coffee|jsx)$/))) {
            scriptType = match[1];
          }
          if ((match = child.match(/^data\.(tsv|csv|json)$/))) {
            dataType = match[1];
          }
        });

        return {
          title: 'e2d3/' + name,
          baseUrl: apiBaseUrl + '/contrib/' + name,
          scriptType: scriptType,
          dataType: dataType
        };
      };

      var dirs = fs.readdirSync(options.contrib);
      var charts = dirs.filter(function (name) { return name.indexOf('.') !== 0; }).map(createData);

      res.json({
        charts: charts
      });
    };
  };

  app.get('/api/categories/develop', api(''));
  app.get('/api/categories/delegate', api('https://localhost:8443'));

  app.use('/contrib', express.static(options.contrib));
  app.use(express.static(path.join(__dirname, '..', 'dist')));

  var setupServer = function (server) { return server; };

  if (options.livereload === -1) {
    var lr = tinylr();
    app.use(lr.handler.bind(lr));
    setupServer = function (server) {
      server.on('upgrade', lr.websocketify.bind(lr));
      server.on('close', lr.close.bind(lr));
      return server;
    };
  }

  if (options.http) {
    setupServer(http.createServer(app)).listen(options.http, function () {
      console.log(colors.green('[E2D3] Webserver started at http://0.0.0.0:' + options.http));
      if (options.livereload === -1) {
        open('http://localhost:' + options.http);
      }
    });
  }
  if (options.https) {
    var privateKey  = fs.readFileSync(path.join(__dirname, '..', 'ssl', 'localhost.key'), 'utf8');
    var certificate = fs.readFileSync(path.join(__dirname, '..', 'ssl', 'localhost.crt'), 'utf8');

    var credentials = { key: privateKey, cert: certificate };

    setupServer(https.createServer(credentials, app)).listen(options.https, function () {
      console.log(colors.green('[E2D3] Webserver(SSL) started at https://0.0.0.0:' + options.https));
      if (options.livereload === -1 && !options.http) {
        open('https://localhost:' + options.https);
      }
    });
  }
};
