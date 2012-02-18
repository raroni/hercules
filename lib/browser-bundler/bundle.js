(function() {
  var Bundle, PackageHandler, SourceFileHandler, fs, glob, path;

  glob = require('glob');

  path = require('path');

  fs = require('fs');

  PackageHandler = require("./package_handler");

  SourceFileHandler = require("./source_file_handler");

  module.exports = Bundle = (function() {

    function Bundle(root_dir) {
      this.packages = new PackageHandler(root_dir);
      this.source_files = new SourceFileHandler(root_dir);
    }

    Bundle.prototype.fileMapAsJSONString = function() {
      var contents, index, output, path, _ref;
      output = "{";
      index = 0;
      _ref = this.source_files.map();
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
