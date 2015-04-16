var express = require('express');
var path = require('path');
var bodyParser = require('body-parser');
var fs = require('fs');

var app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.use((require('connect-livereload'))({ port: 35730 }));

app.get('/api/categories/develop', function (req, res) {
  var createData = function (name) {
    var scriptType = 'js';
    var dataType = 'tsv';

    fs.readdirSync(path.join(__dirname, 'contrib', name)).forEach(function (child) {
      var match = null;
      if (match = child.match(/^main\.(js|coffee|jsx)$/))
        scriptType = match[1];
      if (match = child.match(/^data\.(tsv|csv|json)$/))
        dataType = match[1];
    });

    return {
      title: 'e2d3/' + name,
      baseUrl: '/contrib/' + name,
      scriptType: scriptType,
      dataType: dataType
    };
  };

  var dirs = fs.readdirSync(path.join(__dirname, 'contrib'));
  var charts = dirs.filter(function (name) { return name.indexOf('.') != 0; }).map(createData);

  res.json({
    charts: charts
  });
});

app.use('/contrib', express.static(path.join(__dirname, 'contrib')));
app.use(express.static(path.join(__dirname, 'dist')));

app.listen(process.env.PORT || 8000);
