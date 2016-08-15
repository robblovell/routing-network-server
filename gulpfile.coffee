# Gulp stuff.
gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
sourcemaps = require('gulp-sourcemaps')
touch = require('touch')
path = require('path')
tap = require('gulp-tap')
sh = require('shelljs')
jade = require('gulp-jade')
stylus = require('gulp-stylus')
parallelize = require("concurrent-transform")

threads = 100
useSourceMaps = true
coffeeFiles = ['**/*.coffee']
jadeFiles = ['./views/**/*.jade']
stylusFiles = ['./public/stylesheets/**/*.styl']

handleError = (err) ->
    console.log(err.toString())
    @emit('end')

gulp.task('touch', () ->
    gulp.src(coffeeFiles)
    .pipe(
        tap((file, t) ->
            touch(file.path)
        )
    )
)

gulp.task('coffeescripts', () ->
    gulp.src(coffeeFiles)
    .pipe(parallelize(coffee({bare: true}).on('error', gutil.log), threads))
    .pipe(parallelize((if useSourceMaps then sourcemaps.init() else gutil.noop()), threads))
)

gulp.task('jadescripts', () ->
    gulp.src(jadeFiles)
    .pipe(parallelize(jade().on('error', gutil.log), threads))
)

gulp.task('stylusscripts', () ->
    gulp.src(stylusFiles)
    .pipe(parallelize(stylus().on('error', gutil.log), threads))
)

gulp.task('one',  () ->
    return gulp.src('./css/one.styl')
    .pipe(stylus())
    .pipe(gulp.dest('./css/build'))
)

gulp.task('watch', () ->
    gulp.watch(coffeeFiles, ['coffeescripts'])
    gulp.watch(jadeFiles, ['jadescripts'])
    gulp.watch(stylusFiles, ['stylusscripts'])
)

gulp.task('build', ['coffeescripts','jadescripts','stylusscripts'])

gulp.task('default', ['watch', 'coffeescripts'])

gulp.task('done', (() -> ))
