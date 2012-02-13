(function() {

  (function() {
    var cache, package_files, resolveFilePath, resolveModulePath, resolvePath, source_files;
    source_files = '[[[source_files]]]';
    package_files = '[[[package_files]]]';
    cache = {};
    resolveFilePath = function(path, base_dir) {
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
      return [result.join('/'), path.split('/').slice(0, -1).join('/')];
    };
    resolveModulePath = function(module_name, base_dir) {
      var index, package, package_dir, package_file;
      index = 0;
      while (!package) {
        if (index++ !== 0) base_dir = base_dir.split('/').slice(0, -1).join('/');
        package_dir = resolveFilePath(base_dir + '/node_modules/' + module_name)[0];
        package_file = package_dir + '/package.json';
        package = package_files[package_file];
        if (!package && base_dir === '.') {
          throw new Error("Cannot find module '" + module_name + "'");
        }
      }
      return [resolveFilePath(package_dir + '/' + package.main)[0], package_dir];
    };
    resolvePath = function(path, base_dir) {
      var resolver;
      resolver = path.substring(0, 1) === '.' ? resolveFilePath : resolveModulePath;
      return resolver(path, base_dir);
    };
    return context.require = function(path, base_dir) {
      var module, require, resolved_path, _ref;
      base_dir || (base_dir = '.');
      _ref = resolvePath(path, base_dir), resolved_path = _ref[0], base_dir = _ref[1];
      if (cache[resolved_path]) return cache[resolved_path].exports;
      module = cache[resolved_path] = {
        exports: {}
      };
      require = function(new_path) {
        return context.require(new_path, base_dir);
      };
      source_files[resolved_path](module.exports, require, module);
      return module.exports;
    };
  })(this);

}).call(this);
