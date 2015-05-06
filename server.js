'use strict';

var path = require('path');

var e2d3server = require('./lib/index.js');

e2d3server({
  http: process.env.PORT || 8000,
  https: process.env.PORT || 8443,
  livereload: 35730,
  contrib: path.join(__dirname, 'contrib')
});
