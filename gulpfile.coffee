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

isRelease = gutil.env.release?
isFirst = true

amdoptions =
  shim:
    'bootstrap':
      deps: ['jquery']
    'markdown':
      exports: 'markdown'
    'canvg':
      exports: 'canvg'

gulp.task 'clean', (cb) ->
  if isFirst
    isFirst = false
    rimraf 'dist', cb
  else
    cb()

gulp.task 'lib-scripts', ['clean'], ->
  merge(
    gulp.src [
      'bower_components/requirejs/require.js',
      'src/misc/paths.js'
      ]
    gulp.src bowerFiles().concat [
      'src/misc/libs.js',
      'src/common/**/*.coffee'
      'src/lib/coffee/**/*.coffee',
      ]
      .pipe plumber()
      .pipe filter ['**/*.js', '**/*.coffee']
      .pipe cond ((file) -> path.extname(file.path) == '.coffee'), coffee()
      .pipe amd 'libs', amdoptions
      .pipe concat 'libs.js'
      .pipe plumber.stop()
    )
    .pipe order ['**/require.js', '**/libs.js', '**/paths.js']
    .pipe concat 'libs.js'
    .pipe cond isRelease, uglify preserveComments: 'some'
    .pipe gulp.dest 'dist/lib'

gulp.task 'lib-scripts-standalone', ['clean'], ->
  merge(
    gulp.src [
      'bower_components/requirejs/require.js'
      'src/misc/paths.js',
      'src/misc/standalone.coffee'
      ]
      .pipe plumber()
      .pipe cond ((file) -> path.extname(file.path) == '.coffee'), coffee()
      .pipe plumber.stop()
    gulp.src bowerFiles().concat [
      'src/misc/libs-standalone.js',
      'src/common/**/*.coffee'
      'src/lib/coffee/**/*.coffee',
      ]
      .pipe plumber()
      .pipe filter ['**/*.js', '**/*.coffee']
      .pipe cond ((file) -> path.extname(file.path) == '.coffee'), coffee()
      .pipe amd 'libs-standalone', amdoptions
      .pipe concat 'libs.js'
      .pipe plumber.stop()
    )
    .pipe order ['**/require.js', '**/libs.js', '**/paths.js', '**/standalone.js']
    .pipe concat 'e2d3.js'
    .pipe cond isRelease, uglify preserveComments: 'some'
    .pipe gulp.dest 'dist/lib'

gulp.task 'lib-styles', ['clean'], ->
  gulp.src 'src/lib/scss/main.scss'
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

gulp.task 'lib', ['lib-scripts', 'lib-scripts-standalone', 'lib-styles', 'lib-files']

gulp.task 'apps', ['html', 'scripts', 'files']

gulp.task 'build', ['lib', 'apps']

gulp.task 'watch', ['build'], ->
  gulp.watch ['src/lib/coffee/**/*', 'src/common/**/*', 'src/misc/**/*'], ['lib']
  gulp.watch ['src/lib/scss/**/*'], ['lib-styles']
  gulp.watch 'src/apps/**/*', ['apps']
  gulp.watch ['dist/**/*', 'contrib/**/*', 'server.js', 'lib/**/*'], notifyLivereload

gulp.task 'watch-server', ['build'], ->
  gulp.watch ['src/lib/coffee/**/*', 'src/common/**/*', 'src/misc/**/*'], ['lib']
  gulp.watch ['src/lib/scss/**/*'], ['lib-styles']
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
      lr.changed body: files: [name]
