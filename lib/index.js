'use strict';

var express = require('express');
var path = require('path');
var logger = require('morgan');
var cors = require('cors');
var bodyParser = require('body-parser');
var connectLivereload = require('connect-livereload');
var fs = require('fs');
var http = require('http');
var https = require('https');

module.exports = function (options) {

  var privateKey  = fs.readFileSync(path.join(__dirname, '..', 'ssl', 'localhost.key'), 'utf8');
  var certificate = fs.readFileSync(path.join(__dirname, '..', 'ssl', 'localhost.crt'), 'utf8');

  var credentials = { key: privateKey, cert: certificate };

  var app = express();

  app.use(logger('dev'));
  app.use(cors());

  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({ extended: false }));

  if (options.livereload) {
    app.use(connectLivereload({ port: options.livereload }));
  }

  var api = function (apiBaseUrl) {
    return function (req, res) {
      var createData = function (name) {
        var scriptType = 'js';
        var dataType = 'tsv';

        fs.readdirSync(path.join(options.contrib, name)).forEach(function (child) {
          var match = null;
          if (match = child.match(/^main\.(js|coffee|jsx)$/))
            scriptType = match[1];
          if (match = child.match(/^data\.(tsv|csv|json)$/))
            dataType = match[1];
        });

        return {
          title: 'e2d3/' + name,
          baseUrl: apiBaseUrl + '/contrib/' + name,
          scriptType: scriptType,
          dataType: dataType
        };
      };

      var dirs = fs.readdirSync(options.contrib);
      var charts = dirs.filter(function (name) { return name.indexOf('.') != 0; }).map(createData);

      res.json({
        charts: charts
      });
    };
  };

  app.get('/api/categories/develop', api(''));
  app.get('/api/categories/delegate', api('https://localhost:8443'));

  app.use('/contrib', express.static(options.contrib));
  app.use('/App', express.static(path.join(__dirname, '..', 'dist')));
  app.use(express.static(path.join(__dirname, '..', 'dist')));

  if (options.http) {
    http.createServer(app).listen(options.http);
  }
  if (options.https) {
    https.createServer(credentials, app).listen(options.https);
  }
};
