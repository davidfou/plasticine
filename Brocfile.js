var env = require('broccoli-env').getEnv();

var coffee            = require('broccoli-coffee');
var wrap              = require('broccoli-wrap');
var mergeTrees        = require('broccoli-merge-trees');
var pick              = require('broccoli-static-compiler');
var fs                = require('fs');
var replace           = require('broccoli-replace');


var source = coffee('source', {bare: true});
var vendor = pick('vendor', {srcDir: '/', destDir: '/vendor'});
vendor = mergeTrees([vendor, pick('node_modules/sinon', {srcDir: '/', destDir: '/vendor/sinon'})]);

var main_files = pick(source, {srcDir: '/', destDir: '/', files: ['**/main.js']});
var module_files = pick(source, {srcDir: '/', destDir: '/', files: ['**/!(main).*']});

module_files = wrap(module_files,
  {wrapper: ["define(function(require, exports, module) {\n", "\n});"]}
);

if (env === 'development') {
  var exposeSpecs       = require('./broccoli_tasks/spec_exposer');
  var spec_list = exposeSpecs('source/test/spec');
  module.exports = mergeTrees([module_files, main_files, vendor, spec_list]);
} else {
  var optimizeRequireJs = require('broccoli-requirejs');

  var source = mergeTrees([module_files, main_files, vendor]);
  var app = optimizeRequireJs(source, {requirejs: {
    mainConfigFile: 'app/main.js',
    out: 'plasticine.js',
    optimize: 'none',
    cjsTranslate: true,
    baseUrl: 'app',
    paths: {requireLib: '../vendor/almond/almond'},
    include: ['requireLib']
  }});

  var UMD_before = fs.readFileSync('wrapper/UMD_before.txt', 'utf8');
  var UMD_after  = fs.readFileSync('wrapper/UMD_after.txt', 'utf8');
  var banner     = fs.readFileSync('wrapper/banner.txt', 'utf8');

  app = wrap(app, {wrapper: [banner + UMD_before, UMD_after]})

  app = replace(app, {
    files: ['**/*'],
    patterns: [
      {
        match: 'VERSION',
        replacement: JSON.parse(fs.readFileSync('package.json', 'utf8')).version
      }, {
        match: 'DATE',
        replacement: require('moment')().format('ddd MMM D YYYY H:mm:ss')
      }
    ]
  });

  module.exports = app;
}
