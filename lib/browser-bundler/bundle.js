(function() {
  var Bundle, Package, fs, glob, path,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  glob = require('glob');

  path = require('path');

  fs = require('fs');

  Package = require("./package");

  module.exports = Bundle = (function() {

    function Bundle(root_dir) {
      this.root_dir = root_dir;
      this.stripRootDir = __bind(this.stripRootDir, this);
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
      var map, package, _i, _len, _ref;
      map = {};
      if (this.package.metaData()) map['package.json'] = this.package.metaData();
      _ref = this.package.packages();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        package = _ref[_i];
        map[this.stripRootDir(package.metaDataFile())] = package.metaData();
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

    Bundle.prototype.stripRootDir = function(path) {
      return path.replace(this.root_dir, '').substring(1);
    };

    return Bundle;

  })();

}).call(this);
