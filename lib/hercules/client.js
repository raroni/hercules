(function() {

  (function() {
    var cache, package_files, resolve, resolveFilePath, resolveModulePath, resolvePath, source_files,
      _this = this;
    source_files = '[[source_files]]';
    package_files = '[[package_files]]';
    cache = {};
    resolvePath = function(path, base_dir) {
      var full_path, part, parts, result, _i, _len;
      full_path = base_dir ? [base_dir, path].join('/') : path;
      parts = full_path.split('/');
      result = [];
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        if (part === '..') {
          result.pop();
        } else if (part !== '.') {
          result.push(part);
        }
      }
      return result.join('/');
    };
    resolveFilePath = function(path, base_dir) {
      if (!path.match(/\.js$/)) path += '.js';
      return resolvePath(path, base_dir);
    };
    resolveModulePath = function(module_name, base_dir) {
      var index, package, packageMainPath, package_dir, package_file;
      index = 0;
      while (!package) {
        if (index++ !== 0) base_dir = base_dir.split('/').slice(0, -1).join('/');
        package_dir = resolvePath('node_modules/' + module_name, base_dir);
        package_file = package_dir + '/package.json';
        package = package_files[package_file];
        if (!package && !base_dir) {
          throw new Error("Cannot find module '" + module_name + "'");
        }
      }
      packageMainPath = [package_dir, package.main].join('/');
      return resolveFilePath(packageMainPath);
    };
    resolve = function(path, base_dir) {
      var resolver;
      resolver = path.substring(0, 1) === '.' ? resolveFilePath : resolveModulePath;
      return resolver(path, base_dir);
    };
    return this.require = function(path, base_dir) {
      var base_dir_parts, module, require, resolved_path;
      if (base_dir == null) base_dir = '.';
      resolved_path = resolve(path, base_dir);
      base_dir_parts = resolved_path.split('/');
      base_dir_parts.pop();
      base_dir = base_dir_parts.join('/') || null;
      if (cache[resolved_path]) return cache[resolved_path].exports;
      module = cache[resolved_path] = {
        exports: {}
      };
      require = function(new_path) {
        return _this.require(new_path, base_dir);
      };
      source_files[resolved_path](module.exports, require, module);
      return module.exports;
    };
  }).call(this);

}).call(this);
