'use strict';

var path = require('path');
var fs = require('fs');
var yaml = require('js-yaml');

module.exports = function (prefix, options) {
  return function (req, res) {
    var tags = {};

    if (fs.existsSync(path.join(options.contrib, 'tags.yml'))) {
      (function (data) {
        var extractor = function (name, index) {
          if (typeof tags[name] === 'undefined') { tags[name] = []; }
          tags[name].push({name: this, order: index});
        };

        for (var key in data) {
          if (data.hasOwnProperty(key)) {
            data[key].forEach(extractor.bind(key));
          }
        }
      })(yaml.safeLoad(fs.readFileSync(path.join(options.contrib, 'tags.yml'), 'utf8')));
    }

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
        path: prefix + name,
        scriptType: scriptType,
        dataType: dataType
      };
    };

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
