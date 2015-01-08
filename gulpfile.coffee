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
sass = require 'gulp-ruby-sass'
minify= require 'gulp-minify-css'
uglify = require 'gulp-uglify'
amd = require 'amd-optimize'

isRelease = gutil.env.release?

gulp.task 'clean', (cb) ->
  if isRelease
    rimraf 'dist', cb
  else
    cb()

gulp.task 'js', ['clean'], ->
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

gulp.task 'css', ['clean'], ->
  merge(
    gulp.src bowerFiles()
      .pipe filter '**/*.css'
    gulp.src 'src/lib/scss/main.scss'
      .pipe sass loadPath: [
        'bower_components/bootstrap-sass-official/assets/stylesheets',
        'bower_components/font-awesome/scss'
      ]
    )
    .pipe concat 'main.css'
    .pipe cond isRelease, minify()
    .pipe gulp.dest 'dist/lib'

gulp.task 'misc', ['clean'], ->
  gulp.src bowerFiles()
    .pipe filter ['**/*', '!**/*.js', '!**/*.coffee', '!**/*.css', '!**/*.scss']
    .pipe gulp.dest 'dist/lib'

html = (name, dest) ->
  merge(
    gulp.src 'src/' + name + '/**/*.jade'
      .pipe plumber()
      .pipe jade()
    gulp.src 'src/' + name + '/**/*.coffee'
      .pipe plumber()
      .pipe coffee()
    gulp.src 'src/' + name + '/**/*'
      .pipe plumber()
      .pipe filter ['**/*', '!**/*.jade', '!**/*.coffee']
    )
    .pipe gulp.dest 'dist' + dest

gulp.task 'apps', ['clean'], ->
  html 'apps', ''

gulp.task 'contrib', ['clean'], ->
  html 'contrib', '/contrib'

gulp.task 'build', ['js', 'css', 'misc', 'apps', 'contrib']

gulp.task 'watch', ['build'], ->
  gulp.watch 'src/lib/**/*', ['js','css','misc']
  gulp.watch 'src/apps/**/*', ['apps']
  gulp.watch 'src/contrib/**/*', ['contrib']

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
          template: 'misc/serve-index.tmpl'

gulp.task 'default', ['build']
