'use strict';

var path = require('path');
var fs = require('fs');
var yaml = require('js-yaml');

module.exports = function (options) {
  var tags = (function (tags) {
    var ret = {};
    var extractor = function (name) {
      if (typeof ret[name] === 'undefined') {
        ret[name] = [];
      }
      ret[name].push(key);
    };

    for (var key in tags) {
      if (tags.hasOwnProperty(key)) {
        tags[key].forEach(extractor);
      }
    }

    return ret;
  })(yaml.safeLoad(fs.readFileSync(path.join(options.contrib, 'tags.yml'), 'utf8')));

  var api = function (apiBaseUrl) {
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
        title: 'e2d3/e2d3-contrib/' + name,
        tags: typeof tags[name] !== 'undefined' ? tags[name] : [],
        baseUrl: apiBaseUrl + '/contrib/' + name,
        scriptType: scriptType,
        dataType: dataType
      };
    };

    return function (req, res) {
      var dirs = fs.readdirSync(options.contrib);
      var charts = dirs.filter(function (name) {
        if (name.indexOf('.') === 0) {
          return false;
        }

        var stat = fs.statSync(path.join(options.contrib, name));
        if (!stat.isDirectory()) {
          return false;
        }

        return true;
      }).map(createData);

      res.json({
        charts: charts
      });
    };
  };

  return api;
};
