(function() {
  var PackageHandler, fs, glob, path,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  glob = require('glob');

  path = require('path');

  fs = require('fs');

  module.exports = PackageHandler = (function() {

    function PackageHandler(root_dir) {
      this.root_dir = root_dir;
      this.stripRootDir = __bind(this.stripRootDir, this);
    }

    PackageHandler.prototype.files = function() {
      return this._files || (this._files = this.buildFileList());
    };

    PackageHandler.prototype.buildFileList = function() {
      var files, glob_search_string;
      glob_search_string = path.join(this.root_dir, '**package.json');
      files = glob.sync(glob_search_string);
      return files.map(this.stripRootDir);
    };

    PackageHandler.prototype.map = function() {
      var content, file, file_path, map, _i, _len, _ref;
      map = {};
      _ref = this.files();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        file_path = path.join(this.root_dir, file);
        content = fs.readFileSync(file_path, 'utf-8');
        map[file] = JSON.parse(content);
      }
      return map;
    };

    PackageHandler.prototype.stripRootDir = function(path) {
      return path.replace(this.root_dir, '').substring(1);
    };

    return PackageHandler;

  })();

}).call(this);
