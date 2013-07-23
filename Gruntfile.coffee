LIVERELOAD_PORT = 35729
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)
mountFolder = (connect, dir) ->
  connect.static require("path").resolve(dir)

module.exports = (grunt) ->
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  grunt.initConfig
    watch:
      coffee:
        files: ["app/scripts/{,*/}*.coffee"]
        tasks: ["coffee:dist"]
      compass:
        files: ["app/styles/{,*/}*.{scss,sass}"]
        tasks: ["compass:server"]
      livereload:
        options:
            livereload: LIVERELOAD_PORT
        files: [
          "app/*.html"
          "{.tmp,app}/styles/{,*/}*.css"
          "{.tmp,app}/scripts/{,*/}*.js"
          "app/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}"
        ]

    connect:
      options:
        port: 9000
        hostname: "0.0.0.0"

      livereload:
        options:
          middleware: (connect) ->
            [
              lrSnippet
              mountFolder(connect, ".tmp")
              mountFolder(connect, "app")
            ]

      dist:
        options:
          middleware: (connect) -> [mountFolder(connect, "dist")]

    clean:
      dist:
        files: [
          dot: true
          src: [".tmp", "dist/*", "!dist/.git*"]
        ]

      server: ".tmp"

    coffee:
      dist:
        files: [
          expand: true
          cwd: "app/scripts"
          src: "{,*/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]

    compass:
      options:
        sassDir: "app/styles"
        cssDir: ".tmp/styles"
        generatedImagesDir: ".tmp/images/generated"
        imagesDir: "app/images"
        javascriptsDir: "app/scripts"
        fontsDir: "app/styles/fonts"
        importPath: "app/bower_components"
        httpImagesPath: "/images"
        httpGeneratedImagesPath: "/images/generated"
        httpFontsPath: "/styles/fonts"
        relativeAssets: false

      dist: {}
      server:
        options:
          debugInfo: true

    rev:
      dist:
        files:
          src: [
            "dist/scripts/{,*/}*.js"
            "dist/styles/{,*/}*.css"
            "dist/images/{,*/}*.{png,jpg,jpeg,gif,webp}"
            "dist/styles/fonts/*"
          ]

    useminPrepare:
      options:
        dest: "dist"

      html: "app/index.html"

    usemin:
      options:
        dirs: ["dist"]

      html: ["dist/{,*/}*.html"]
      css: ["dist/styles/{,*/}*.css"]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: "app/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "dist/images"
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "app/images"
          src: "{,*/}*.svg"
          dest: "dist/images"
        ]

    cssmin: {}

    htmlmin:
      dist:
        options: {}

        files: [
          expand: true
          cwd: "app"
          src: "*.html"
          dest: "dist"
        ]

    copy:
      dist:
        files: [{
          expand: true
          dot: true
          cwd: "app"
          dest: "dist"
          src: ["*.{ico,png,txt}", "images/{,*/}*.{webp,gif}", "styles/fonts/*"]
        }, {
          expand: true
          cwd: ".tmp/images"
          dest: "dist/images"
          src: ["generated/*"]
        }]

    concurrent:
      server: ["compass", "coffee:dist"]
      test: ["coffee"]
      dist: ["coffee", "compass", "imagemin", "svgmin", "htmlmin"]

  grunt.registerTask "server", (target) ->
    if target is "dist"
      return grunt.task.run(["build", "connect:dist:keepalive"])

    grunt.task.run ["clean:server", "concurrent:server", "connect:livereload", "watch"]

  grunt.registerTask "build", [
    "clean:dist"
    "useminPrepare"
    "concurrent:dist"
    "concat"
    "cssmin"
    "uglify"
    "copy:dist"
    "rev"
    "usemin"
  ]
  grunt.registerTask "default", ["build"]