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
        ]

    connect:
      options:
        port: process.env.PORT or 9001
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
        javascriptsDir: "app/scripts"
        importPath: "app/bower_components"
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
          ]

    copy:
      dist:
        flatten: true
        expand: true
        src: ["app/bower_components/ace-builds/src/worker-json.js"]
        dest: "dist/"

    useminPrepare:
      options:
        dest: "dist"

      html: "app/index.html"

    usemin:
      options:
        dirs: ["dist"]

      html: ["dist/{,*/}*.html"]
      css: ["dist/styles/{,*/}*.css"]

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

    concurrent:
      server: ["compass", "coffee:dist"]
      test: ["coffee"]
      dist: ["coffee", "compass", "htmlmin"]

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
    "rev"
    "usemin"
    "copy"
  ]

  grunt.registerTask "default", ["build"]