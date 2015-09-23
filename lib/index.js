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

  var api = require('./api')(options);

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
      if (process.send) {
        process.send('Server listening at http://0.0.0.0:' + options.http);
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
