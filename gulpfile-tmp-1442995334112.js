(function() {
  var amd, bowerFiles, coffee, concat, cond, debug, filter, gulp, gutil, isFirst, isRelease, jade, lr, merge, minify, notifyLivereload, order, path, plumber, rimraf, sass, server, sourcemaps, startExpress, startLivereload, uglify;

  gulp = require('gulp');

  gutil = require('gulp-util');

  debug = require('gulp-debug');

  rimraf = require('rimraf');

  merge = require('merge2');

  path = require('path');

  cond = require('gulp-if');

  filter = require('gulp-filter');

  order = require('gulp-order');

  concat = require('gulp-concat');

  server = require('gulp-develop-server');

  plumber = require('gulp-plumber');

  bowerFiles = require('main-bower-files');

  sourcemaps = require('gulp-sourcemaps');

  jade = require('gulp-jade');

  coffee = require('gulp-coffee');

  sass = require('gulp-sass');

  minify = require('gulp-minify-css');

  uglify = require('gulp-uglify');

  amd = require('amd-optimize');

  isRelease = gutil.env.release != null;

  isFirst = true;

  gulp.task('clean', function(cb) {
    if (isFirst) {
      isFirst = false;
      return rimraf('dist', cb);
    } else {
      return cb();
    }
  });

  gulp.task('lib-scripts', ['clean'], function() {
    var options;
    options = {
      shim: {
        'bootstrap': {
          deps: ['jquery']
        },
        'markdown': {
          exports: 'markdown'
        },
        'canvg': {
          exports: 'canvg'
        }
      }
    };
    return merge(gulp.src('bower_components/requirejs/require.js'), merge(gulp.src(bowerFiles()).pipe(filter('**/*.js')), gulp.src('src/misc/libs.js'), gulp.src('src/lib/js/*.js'), gulp.src('src/lib/coffee/*.coffee').pipe(plumber()).pipe(coffee())).pipe(amd('libs', options)).pipe(concat('libs.js')), gulp.src('src/misc/paths.js')).pipe(order(['**/require.js', '**/libs.js', '**/paths.js'])).pipe(concat('libs.js')).pipe(cond(isRelease, uglify({
      preserveComments: 'some'
    }))).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('lib-scripts-standalone', ['clean'], function() {
    var options;
    options = {
      shim: {
        'bootstrap': {
          deps: ['jquery']
        },
        'markdown': {
          exports: 'markdown'
        },
        'canvg': {
          exports: 'canvg'
        }
      }
    };
    return merge(gulp.src('bower_components/requirejs/require.js'), merge(gulp.src(bowerFiles()).pipe(filter('**/*.js')), gulp.src('src/misc/libs-standalone.js'), gulp.src('src/lib/js/*.js'), gulp.src('src/lib/coffee/*.coffee').pipe(plumber()).pipe(coffee())).pipe(amd('libs-standalone', options)).pipe(concat('libs.js')), gulp.src('src/misc/paths.js'), gulp.src('src/misc/standalone.coffee').pipe(plumber()).pipe(coffee())).pipe(order(['**/require.js', '**/libs.js', '**/paths.js', '**/standalone.coffee'])).pipe(concat('e2d3.js')).pipe(cond(isRelease, uglify({
      preserveComments: 'some'
    }))).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('lib-styles', ['clean'], function() {
    return gulp.src('src/lib/scss/main.scss').pipe(plumber()).pipe(sass({
      precision: 8
    })).pipe(concat('main.css')).pipe(cond(isRelease, minify())).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('lib-files', ['clean'], function() {
    return gulp.src(bowerFiles()).pipe(filter(['**/*', '!**/*.js', '!**/*.coffee', '!**/*.css', '!**/*.scss'])).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('html', ['clean'], function() {
    return gulp.src('src/apps/**/*.jade').pipe(plumber()).pipe(jade({
      pretty: true
    })).pipe(gulp.dest('dist'));
  });

  gulp.task('scripts', ['clean'], function() {
    return gulp.src('src/apps/**/*.coffee').pipe(plumber()).pipe(sourcemaps.init()).pipe(coffee()).pipe(sourcemaps.write()).pipe(gulp.dest('dist'));
  });

  gulp.task('files', ['clean'], function() {
    return gulp.src('src/apps/**/*').pipe(plumber()).pipe(filter(['**/*', '!**/*.jade', '!**/*.coffee'])).pipe(gulp.dest('dist'));
  });

  gulp.task('lib', ['lib-scripts', 'lib-scripts-standalone', 'lib-styles', 'lib-files']);

  gulp.task('apps', ['html', 'scripts', 'files']);

  gulp.task('build', ['lib', 'apps']);

  gulp.task('watch', ['build'], function() {
    gulp.watch(['src/lib/**/*', 'src/misc/**/*'], ['lib']);
    gulp.watch('src/apps/**/*', ['apps']);
    return gulp.watch(['dist/**/*', 'contrib/**/*', 'server.js', 'lib/index.js'], notifyLivereload);
  });

  gulp.task('watch-server', ['build'], function() {
    gulp.watch(['src/lib/**/*', 'src/misc/**/*'], ['lib']);
    return gulp.watch('src/apps/**/*', ['apps']);
  });

  gulp.task('run', ['watch'], function() {
    startExpress();
    return startLivereload();
  });

  gulp.task('default', ['build']);

  startExpress = function() {
    return server.listen({
      path: 'server.js',
      delay: 0
    });
  };

  lr = null;

  startLivereload = function() {
    lr = (require('tiny-lr'))();
    return lr.listen(35730);
  };

  notifyLivereload = function(event) {
    var dist, name;
    dist = path.join(__dirname, 'dist');
    name = path.relative(dist, event.path);
    if (/^\.\.\/contrib\//.test(name)) {
      name = name.substring(3);
    }
    return server.changed(function(error) {
      if (!error) {
        return lr.changed({
          body: {
            files: [name]
          }
        });
      }
    });
  };

}).call(this);
