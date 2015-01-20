gulp = require 'gulp'
gutil = require 'gulp-util'
debug = require 'gulp-debug'

rimraf = require 'rimraf'
merge = require 'merge2'

cond = require 'gulp-if'
filter = require 'gulp-filter'
order = require 'gulp-order'
concat = require 'gulp-concat'

webserver = require 'gulp-webserver'
plumber = require 'gulp-plumber'
bowerFiles = require 'main-bower-files'

jade = require 'gulp-jade'
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'
minify= require 'gulp-minify-css'
uglify = require 'gulp-uglify'
amd = require 'amd-optimize'

isRelease = gutil.env.release?
isFirst = true

gulp.task 'clean', (cb) ->
  if isFirst
    isFirst = false
    rimraf 'dist', cb
  else
    cb()

gulp.task 'lib', ['clean'], ->
  # js
  options =
    paths:
      'bootstrap': 'bower_components/bootstrap-sass-official/assets/javascripts/bootstrap'
    shim:
      'bootstrap':
        deps: ['jquery']
      'markdown':
        exports: 'markdown'

  merge(
    gulp.src 'bower_components/requirejs/require.js'
    merge(
      gulp.src bowerFiles()
        .pipe filter '**/*.js'
      gulp.src 'src/lib/js/*.js'
      gulp.src 'src/lib/coffee/*.coffee'
        .pipe coffee()
      )
      .pipe amd 'libs', options
      .pipe concat 'libs.js'
    )
    .pipe order ['**/require.js', '**/libs.js']
    .pipe concat 'libs.js'
    .pipe cond isRelease, uglify preserveComments: 'some'
    .pipe gulp.dest 'dist/lib'

  merge(
    gulp.src 'bower_components/react/JSXTransformer.js'
    gulp.src 'bower_components/jsx-requirejs-plugin/js/jsx.js'
    )
    .pipe cond isRelease, uglify preserveComments: 'some'
    .pipe gulp.dest 'dist/lib'

  # css
  gulp.src bowerFiles()
    .pipe filter '**/*.css'
    .pipe concat 'libs.css'
    .pipe cond isRelease, minify()
    .pipe gulp.dest 'dist/lib'

  gulp.src 'src/lib/scss/main.scss'
    .pipe sass()
    .pipe concat 'main.css'
    .pipe cond isRelease, minify()
    .pipe gulp.dest 'dist/lib'

  # misc
  gulp.src bowerFiles()
    .pipe filter ['**/*', '!**/*.js', '!**/*.coffee', '!**/*.css', '!**/*.scss']
    .pipe gulp.dest 'dist/lib'

gulp.task 'apps', ['clean'], ->
  merge(
    gulp.src 'src/apps/**/*.jade'
      .pipe plumber()
      .pipe jade()
    gulp.src 'src/apps/**/*.coffee'
      .pipe plumber()
      .pipe coffee()
    gulp.src 'src/apps/**/*'
      .pipe plumber()
      .pipe filter ['**/*', '!**/*.jade', '!**/*.coffee']
    )
    .pipe gulp.dest 'dist'

gulp.task 'contrib', ['clean'], ->
  gulp.src 'contrib/**/*'
    .pipe gulp.dest 'dist/contrib'

gulp.task 'build', ['lib', 'apps', 'contrib']

gulp.task 'watch', ['build'], ->
  gulp.watch 'src/lib/**/*', ['lib']
  gulp.watch 'src/apps/**/*', ['apps']
  gulp.watch 'contrib/**/*', ['contrib']

gulp.task 'run', ['watch'], ->
  gulp.src 'dist'
    .pipe webserver
      host: '0.0.0.0'
      port: 8000
      livereload:
        enable: true
        port: 35730
      directoryListing:
        enable: true
        path: 'dist'
        options:
          template: 'src/misc/serve-index.tmpl'

gulp.task 'default', ['build']
