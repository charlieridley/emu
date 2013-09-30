"use strict";

module.exports = function(grunt) {

    require("matchdep").filterDev("grunt-*").forEach(grunt.loadNpmTasks);
    grunt.initConfig({

        // Define Directory
        dirs: {
            tmp: ".tmp",
            coffee: "src",
            build:  "dist"
        },

        // Metadata
        pkg: grunt.file.readJSON("package.json"),
        banner:
        "\n" +
        "/*\n" +
         " * -------------------------------------------------------\n" +
         " * Project: <%= pkg.title %>\n" +
         " * Version: <%= grunt.option('gitRevision') %>\n" +
         " *\n" +
         " * Author:  <%= pkg.author.name %>\n" +
         " * Site:     <%= pkg.author.url %>\n" +
         " * Contact: <%= pkg.author.email %>\n" +
         " *\n" +
         " *\n" +
         " * Copyright (c) <%= grunt.template.today(\"yyyy\") %> <%= pkg.author.name %>\n" +
         " * -------------------------------------------------------\n" +
         " */\n" +
         "\n",

         clean: [
            "<%= dirs.tmp %>/*",
            "<%= dirs.build %>/*"
        ],

        // Compile CoffeeScript
        coffee: {
          compile:{
            options: {
              bare: true
            },
            expand: true,
            cwd: "<%= dirs.coffee %>",
            src: ['**/*.js.coffee'],
            dest: "<%= dirs.tmp %>",
            ext: '.js'
          }
        },

        neuter: {
          emu: {
            options: {
                filepathTransform: function (filepath) {
                    return '.tmp/emu/' + filepath;
                }
            },
            src: "<%= dirs.tmp %>/emu/emu.js",
            dest: "<%= dirs.build %>/ember-emu-<%= pkg.version %>.js"
          },
          emu_signalr: {
            options: {
                filepathTransform: function (filepath) {
                    return '.tmp/emu/' + filepath;
                }
            },
            src: "<%= dirs.tmp %>/emu-signalr/signalr_push_data_adapter.js",
            dest: "<%= dirs.build %>/ember-emu-signalr-<%= pkg.version %>.js"
          }
        },

        // Minify and Concat archives
        uglify: {
            options: {
                mangle: true,
                banner: "<%= banner %>"
            },
            dist: {
              files: {
                  "<%= dirs.build %>/ember-emu-<%= pkg.version %>.min.js": "<%= dirs.build %>/ember-emu-<%= pkg.version %>.js",
                  "<%= dirs.build %>/ember-emu-signalr-<%= pkg.version %>.min.js": "<%= dirs.build %>/ember-emu-signalr-<%= pkg.version %>.js"
              }
            }
        },

        // Notifications
        notify: {
          coffee: {
            options: {
              title: "CoffeeScript - <%= pkg.title %>",
              message: "Compiled and minified with success!"
            }
          },
          js: {
            options: {
              title: "Javascript - <%= pkg.title %>",
              message: "Minified and validated with success!"
            }
          }
        },

        "git-describe" : {
          app:{
          }
        }
    });


    // Register Taks
    // --------------------------

    // Observe changes, concatenate, minify and validate files
    grunt.registerTask( "default", ["saveRevision", "clean", "coffee", "notify:coffee", "neuter", "uglify", "notify:js" ]);
    grunt.registerTask('saveRevision', function() {
      grunt.event.once('git-describe', function (rev) {
        grunt.log.writeln("Git Revision: " + rev);
        grunt.option('gitRevision', rev);
      });
      grunt.task.run('git-describe');
    });
};