(function() {
  var SourceFileHandler, fs, glob, path,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  glob = require('glob');

  path = require('path');

  fs = require('fs');

  module.exports = SourceFileHandler = (function() {

    function SourceFileHandler(root_dir) {
      this.root_dir = root_dir;
      this.stripRootDir = __bind(this.stripRootDir, this);
      this.shouldBeIncluded = __bind(this.shouldBeIncluded, this);
    }

    SourceFileHandler.prototype.files = function() {
      return this._list || (this._list = this.buildList());
    };

    SourceFileHandler.prototype.buildList = function() {
      var files, glob_search_string;
      glob_search_string = path.join(this.root_dir, '**.**');
      files = glob.sync(glob_search_string);
      files = files.filter(this.shouldBeIncluded);
      return files.map(this.stripRootDir);
    };

    SourceFileHandler.prototype.shouldBeIncluded = function(file) {
      var ext;
      ext = path.extname(file).substring(1);
      return ext === 'js' || this.isCompilable(ext);
    };

    SourceFileHandler.prototype.isCompilable = function(extension) {
      return extension === 'coffee';
    };

    SourceFileHandler.prototype.map = function() {
      var file, file_path, map, _i, _len, _ref;
      map = {};
      _ref = this.files();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        file_path = path.join(this.root_dir, file);
        map[file.replace('.js', '')] = fs.readFileSync(file_path, 'utf-8');
      }
      return map;
    };

    SourceFileHandler.prototype.stripRootDir = function(path) {
      return path.replace(this.root_dir, '').substring(1);
    };

    return SourceFileHandler;

  })();

}).call(this);
