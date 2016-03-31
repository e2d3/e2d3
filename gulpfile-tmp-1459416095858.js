(function() {
  var amd, amdoptions, bowerFiles, coffee, concat, cond, debug, filter, gulp, gutil, isFirst, isRelease, jade, lr, merge, minify, notifyLivereload, order, path, plumber, rimraf, sass, server, sourcemaps, startExpress, startLivereload, uglify, vueloader;

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

  vueloader = require('./lib/vueloader');

  isRelease = gutil.env.release != null;

  isFirst = true;

  amdoptions = {
    shim: {
      'bootstrap': {
        deps: ['jquery']
      },
      'canvg': {
        exports: 'canvg'
      },
      'colorbrewer': {
        exports: 'colorbrewer'
      }
    },
    loader: vueloader('src/scripts')
  };

  gulp.task('clean', function(cb) {
    if (isFirst) {
      isFirst = false;
      return rimraf('dist', cb);
    } else {
      return cb();
    }
  });

  gulp.task('lib-scripts-full', ['clean'], function() {
    return merge(gulp.src(['bower_components/requirejs/require.js', 'src/scripts-gen/paths.js']), gulp.src(bowerFiles().concat(['src/build/e2d3full.js', 'src/scripts/**/*.coffee', 'src/scripts/**/*.vue'])).pipe(plumber()).pipe(filter(['**/*.js', '**/*.coffee', '**/*.vue'])).pipe(cond((function(file) {
      return path.extname(file.path) === '.coffee';
    }), coffee())).pipe(amd('e2d3full', amdoptions)).pipe(concat('libs.js')).pipe(plumber.stop())).pipe(order(['**/require.js', '**/libs.js', '**/paths.js'])).pipe(concat('e2d3full.js')).pipe(cond(isRelease, uglify({
      preserveComments: 'some'
    }))).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('lib-scripts-core', ['clean'], function() {
    return merge(gulp.src(['bower_components/requirejs/require.js', 'src/scripts-gen/paths.js', 'src/scripts/standalone.coffee']).pipe(plumber()).pipe(cond((function(file) {
      return path.extname(file.path) === '.coffee';
    }), coffee())).pipe(plumber.stop()), gulp.src(bowerFiles().concat(['src/build/e2d3core.js', 'src/scripts/**/*.coffee', 'src/scripts/**/*.vue'])).pipe(plumber()).pipe(filter(['**/*.js', '**/*.coffee', '**/*.vue'])).pipe(cond((function(file) {
      return path.extname(file.path) === '.coffee';
    }), coffee())).pipe(amd('e2d3core', amdoptions)).pipe(concat('e2d3.js')).pipe(plumber.stop())).pipe(order(['**/require.js', '**/libs.js', '**/paths.js', '**/standalone.js'])).pipe(concat('e2d3.js')).pipe(cond(isRelease, uglify({
      preserveComments: 'some'
    }))).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('lib-styles', ['clean'], function() {
    return gulp.src('src/styles/main.scss').pipe(sass({
      precision: 8
    })).on('error', sass.logError).pipe(concat('main.css')).pipe(cond(isRelease, minify())).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('lib-files', ['clean'], function() {
    return gulp.src(bowerFiles()).pipe(filter(['**/*', '!**/*.js', '!**/*.coffee', '!**/*.css', '!**/*.scss'])).pipe(gulp.dest('dist/lib'));
  });

  gulp.task('html', ['clean'], function() {
    return gulp.src('src/apps/**/*.jade').pipe(plumber()).pipe(jade({
      pretty: true
    })).pipe(plumber.stop()).pipe(gulp.dest('dist'));
  });

  gulp.task('scripts', ['clean'], function() {
    return gulp.src('src/apps/**/*.coffee').pipe(plumber()).pipe(sourcemaps.init()).pipe(coffee()).pipe(sourcemaps.write()).pipe(plumber.stop()).pipe(gulp.dest('dist'));
  });

  gulp.task('files', ['clean'], function() {
    return gulp.src('src/apps/**/*').pipe(filter(['**/*', '!**/*.jade', '!**/*.js', '!**/*.coffee'])).pipe(gulp.dest('dist'));
  });

  gulp.task('lib', ['lib-scripts-full', 'lib-scripts-core', 'lib-styles', 'lib-files']);

  gulp.task('apps', ['html', 'scripts', 'files']);

  gulp.task('build', ['lib', 'apps']);

  gulp.task('watch', ['build'], function() {
    gulp.watch(['src/scripts/**/*', 'src/build/**/*'], ['lib']);
    gulp.watch(['src/styles/**/*'], ['lib-styles']);
    gulp.watch('src/apps/**/*', ['apps']);
    return gulp.watch(['dist/**/*', 'contrib/**/*', 'server.js', 'lib/**/*'], notifyLivereload);
  });

  gulp.task('watch-server', ['build'], function() {
    gulp.watch(['src/scripts/**/*', 'src/build/**/*'], ['lib']);
    gulp.watch(['src/styles/**/*'], ['lib-styles']);
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
