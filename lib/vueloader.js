'use strict';

var path = require('path');
var amd = require('amd-optimize');
var vueify = require('vueify');
var through = require('through2');

module.exports = function (basePath) {
  return amd.loader(function (moduleName) {
    return path.join(basePath, moduleName);
  }, function () {
    var translator = function (file, enc, cb) {
      var fileContents = file.contents.toString('utf8');
      var filePath = file.path;

      vueify.compiler.compile(fileContents, filePath, function (err, result) {
        var js = 'define(function (require, exports, module) {\n' + result + '});\n';
        file.path = filePath.replace(/\.vue$/, '.js');
        file.contents = new Buffer(js);
        cb(null, file);
      });
    };

    return through.obj(translator);
  });
};
