(function() {
  var Bundle, PackageHandler, fs, glob, path,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  glob = require('glob');

  path = require('path');

  fs = require('fs');

  PackageHandler = require("./package_handler");

  module.exports = Bundle = (function() {

    function Bundle(root_dir) {
      this.root_dir = root_dir;
      this.stripRootDir = __bind(this.stripRootDir, this);
      this.sourceFileShouldBeIncluded = __bind(this.sourceFileShouldBeIncluded, this);
      this.packages = new PackageHandler(this.root_dir);
    }

    Bundle.prototype.sourceFiles = function() {
      return this._source_files || (this._source_files = this.buildSourceFileList());
    };

    Bundle.prototype.buildSourceFileList = function() {
      var files, glob_search_string;
      glob_search_string = path.join(this.root_dir, '**.**');
      files = glob.sync(glob_search_string);
      files = files.filter(this.sourceFileShouldBeIncluded);
      return files.map(this.stripRootDir);
    };

    Bundle.prototype.sourceFileShouldBeIncluded = function(file) {
      var ext;
      ext = path.extname(file).substring(1);
      return ext === 'js' || this.isCompilable(ext);
    };

    Bundle.prototype.isCompilable = function(extension) {
      return extension === 'coffee';
    };

    Bundle.prototype.sourceFileMap = function() {
      var file, file_path, map, _i, _len, _ref;
      map = {};
      _ref = this.sourceFiles();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        file_path = path.join(this.root_dir, file);
        map[file.replace('.js', '')] = fs.readFileSync(file_path, 'utf-8');
      }
      return map;
    };

    Bundle.prototype.stripRootDir = function(path) {
      return path.replace(this.root_dir, '').substring(1);
    };

    Bundle.prototype.fileMapAsJSONString = function() {
      var contents, index, output, path, _ref;
      output = "{";
      index = 0;
      _ref = this.sourceFileMap();
      for (path in _ref) {
        contents = _ref[path];
        if (index++ !== 0) output += ", ";
        output += JSON.stringify(path);
        output += ':';
        output += "function(exports, require, module) { " + contents + " }";
      }
      return output += "}";
    };

    Bundle.prototype.toString = function() {
      var client_js, client_path;
      client_path = path.join(__dirname, 'client.js');
      client_js = fs.readFileSync(client_path, 'utf-8');
      client_js = client_js.replace("'[[[source_files]]]'", this.fileMapAsJSONString());
      client_js = client_js.replace("'[[[package_files]]]'", JSON.stringify(this.packages.map()));
      return client_js;
    };

    return Bundle;

  })();

}).call(this);
