gulp = require 'gulp'
gutil = require 'gulp-util'
debug = require 'gulp-debug'

rimraf = require 'rimraf'
merge = require 'merge2'
path = require 'path'

cond = require 'gulp-if'
filter = require 'gulp-filter'
order = require 'gulp-order'
concat = require 'gulp-concat'

server = require 'gulp-develop-server'
plumber = require 'gulp-plumber'
bowerFiles = require 'main-bower-files'
sourcemaps = require 'gulp-sourcemaps'

jade = require 'gulp-jade'
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'
minify = require 'gulp-minify-css'
uglify = require 'gulp-uglify'
amd = require 'amd-optimize'
vueloader = require './lib/vueloader'

isRelease = gutil.env.release?
isFirst = true

amdoptions =
  shim:
    'bootstrap':
      deps: ['jquery']
    'canvg':
      exports: 'canvg'
  loader: vueloader 'src/scripts'

gulp.task 'clean', (cb) ->
  if isFirst
    isFirst = false
    rimraf 'dist', cb
  else
    cb()

gulp.task 'lib-scripts-full', ['clean'], ->
  merge(
    gulp.src [
      'bower_components/requirejs/require.js',
      'src/scripts-gen/paths.js'
      ]
    gulp.src bowerFiles().concat [
      'src/build/e2d3full.js',
      'src/scripts/**/*.coffee',
      'src/scripts/**/*.vue',
      ]
      .pipe plumber()
      .pipe filter ['**/*.js', '**/*.coffee', '**/*.vue']
      .pipe cond ((file) -> path.extname(file.path) == '.coffee'), coffee()
      .pipe amd 'e2d3full', amdoptions
      .pipe concat 'libs.js'
      .pipe plumber.stop()
    )
    .pipe order ['**/require.js', '**/libs.js', '**/paths.js']
    .pipe concat 'e2d3full.js'
    .pipe cond isRelease, uglify preserveComments: 'some'
    .pipe gulp.dest 'dist/lib'

gulp.task 'lib-scripts-core', ['clean'], ->
  merge(
    gulp.src [
      'bower_components/requirejs/require.js'
      'src/scripts-gen/paths.js',
      'src/scripts/standalone.coffee'
      ]
      .pipe plumber()
      .pipe cond ((file) -> path.extname(file.path) == '.coffee'), coffee()
      .pipe plumber.stop()
    gulp.src bowerFiles().concat [
      'src/build/e2d3core.js',
      'src/scripts/**/*.coffee',
      'src/scripts/**/*.vue',
      ]
      .pipe plumber()
      .pipe filter ['**/*.js', '**/*.coffee', '**/*.vue']
      .pipe cond ((file) -> path.extname(file.path) == '.coffee'), coffee()
      .pipe amd 'e2d3core', amdoptions
      .pipe concat 'e2d3.js'
      .pipe plumber.stop()
    )
    .pipe order ['**/require.js', '**/libs.js', '**/paths.js', '**/standalone.js']
    .pipe concat 'e2d3.js'
    .pipe cond isRelease, uglify preserveComments: 'some'
    .pipe gulp.dest 'dist/lib'

gulp.task 'lib-styles', ['clean'], ->
  gulp.src 'src/styles/main.scss'
    .pipe sass precision: 8
      .on 'error', sass.logError
    .pipe concat 'main.css'
    .pipe cond isRelease, minify()
    .pipe gulp.dest 'dist/lib'

gulp.task 'lib-files', ['clean'], ->
  gulp.src bowerFiles()
    .pipe filter ['**/*', '!**/*.js', '!**/*.coffee', '!**/*.css', '!**/*.scss']
    .pipe gulp.dest 'dist/lib'

gulp.task 'html', ['clean'], ->
  gulp.src 'src/apps/**/*.jade'
    .pipe plumber()
    .pipe jade pretty: true
    .pipe plumber.stop()
    .pipe gulp.dest 'dist'

gulp.task 'scripts', ['clean'], ->
  gulp.src 'src/apps/**/*.coffee'
    .pipe plumber()
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe sourcemaps.write()
    .pipe plumber.stop()
    .pipe gulp.dest 'dist'

gulp.task 'files', ['clean'], ->
  gulp.src 'src/apps/**/*'
    .pipe filter ['**/*', '!**/*.jade', '!**/*.js', '!**/*.coffee']
    .pipe gulp.dest 'dist'

gulp.task 'lib', ['lib-scripts-full', 'lib-scripts-core', 'lib-styles', 'lib-files']

gulp.task 'apps', ['html', 'scripts', 'files']

gulp.task 'build', ['lib', 'apps']

gulp.task 'watch', ['build'], ->
  gulp.watch ['src/scripts/**/*', 'src/build/**/*'], ['lib']
  gulp.watch ['src/styles/**/*'], ['lib-styles']
  gulp.watch 'src/apps/**/*', ['apps']
  gulp.watch ['dist/**/*', 'contrib/**/*', 'server.js', 'lib/**/*'], notifyLivereload

gulp.task 'watch-server', ['build'], ->
  gulp.watch ['src/scripts/**/*', 'src/build/**/*'], ['lib']
  gulp.watch ['src/styles/**/*'], ['lib-styles']
  gulp.watch 'src/apps/**/*', ['apps']

gulp.task 'run', ['watch'], ->
  startExpress()
  startLivereload()

gulp.task 'default', ['build']

startExpress = () ->
  server.listen
    path: 'server.js'
    delay: 0

lr = null
startLivereload = () ->
  lr = (require 'tiny-lr')()
  lr.listen 35730

notifyLivereload = (event) ->
  dist = path.join __dirname, 'dist'
  name = path.relative dist, event.path
  name = name.substring 3 if /^\.\.\/contrib\//.test name
  server.changed (error) ->
    if !error
      # change gulp-develop-server/index.js
      #   return done( null, 'Development server already received restart requests.', callback );
      #     ->  return done( 'Development server already received restart requests.', callback );
      lr.changed body: files: [name]
