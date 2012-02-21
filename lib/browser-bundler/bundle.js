(function() {
  var Bundle, Package, fs, glob, path;

  glob = require('glob');

  path = require('path');

  fs = require('fs');

  Package = require("./package");

  module.exports = Bundle = (function() {

    function Bundle(root_dir) {
      this.root_dir = root_dir;
      this.package = new Package(this.root_dir);
    }

    Bundle.prototype.readFile = function(file) {
      return fs.readFileSync(path.join(this.root_dir, file), 'utf-8');
    };

    Bundle.prototype.sourceFilesAsJSON = function() {
      var contents, file, index, output, _i, _len, _ref;
      output = "{";
      index = 0;
      _ref = this.package.sourceFiles();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        contents = this.readFile(file);
        if (index++ !== 0) output += ", ";
        output += JSON.stringify(file.replace('.js', ''));
        output += ':';
        output += "function(exports, require, module) { " + contents + " }";
      }
      return output += "}";
    };

    Bundle.prototype.packageFilesAsJSON = function() {
      var contents, file, map, _i, _len, _ref;
      map = {};
      _ref = this.package.packageFiles();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        contents = this.readFile(file);
        map[file] = JSON.parse(contents);
      }
      return JSON.stringify(map);
    };

    Bundle.prototype.toString = function() {
      var client_js, client_path;
      client_path = path.join(__dirname, 'client.js');
      client_js = fs.readFileSync(client_path, 'utf-8');
      client_js = client_js.replace("'[[[source_files]]]'", this.sourceFilesAsJSON());
      client_js = client_js.replace("'[[[package_files]]]'", this.packageFilesAsJSON());
      return client_js;
    };

    return Bundle;

  })();

}).call(this);
