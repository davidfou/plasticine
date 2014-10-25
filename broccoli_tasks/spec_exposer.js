var Writer = require('broccoli-writer');

module.exports = ExposeSpecs;

ExposeSpecs.prototype = Object.create(Writer.prototype);
function ExposeSpecs (inputTree) {
  if (!(this instanceof ExposeSpecs)) return new ExposeSpecs(inputTree);
  this.inputTree = inputTree;
};

ExposeSpecs.prototype.write = function (readTree, destDir) {
  readTree(this.inputTree).then( function(srcDir) {
    var fs, getFiles, main_node, path;

    fs = require('fs');

    path = require('path');

    getFiles = function(dir) {
      var file, files, name, node, _i, _len;
      node = {
        name: dir.split(path.sep).pop(),
        files: [],
        directories: []
      };
      files = fs.readdirSync(dir);
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        name = dir + path.sep + file;
        if (fs.statSync(name).isDirectory()) {
          node.directories.push(getFiles(name));
        } else {
          if (path.extname(file) === '.coffee') {
            node.files.push(path.basename(file, '.coffee') + '.js');
          }
        }
      }
      return node;
    };

    main_node = getFiles(srcDir);
    fs.writeFileSync(path.join(destDir, 'list.json'), JSON.stringify(main_node));
  });
};
