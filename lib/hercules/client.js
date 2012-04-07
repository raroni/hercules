(function() {

  (function() {
    var cache, packageFiles, resolve, resolveFilePath, resolveModulePath, resolvePath, sourceFiles,
      _this = this;
    sourceFiles = '[[sourceFiles]]';
    packageFiles = '[[packageFiles]]';
    cache = {};
    resolvePath = function(path, baseDir) {
      var fullPath, part, parts, result, _i, _len;
      fullPath = baseDir ? [baseDir, path].join('/') : path;
      parts = fullPath.split('/');
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
    resolveFilePath = function(path, baseDir) {
      if (!path.match(/\.js$/)) path += '.js';
      return resolvePath(path, baseDir);
    };
    resolveModulePath = function(moduleName, baseDir) {
      var index, package, packageDir, packageFile, packageMainPath;
      index = 0;
      while (!package) {
        if (index++ !== 0) baseDir = baseDir.split('/').slice(0, -1).join('/');
        packageDir = resolvePath('node_modules/' + moduleName, baseDir);
        packageFile = packageDir + '/package.json';
        package = packageFiles[packageFile];
        if (!package && !baseDir) {
          throw new Error("Cannot find module '" + moduleName + "'");
        }
      }
      packageMainPath = [packageDir, package.main].join('/');
      return resolveFilePath(packageMainPath);
    };
    resolve = function(path, baseDir) {
      var resolver;
      resolver = path.substring(0, 1) === '.' ? resolveFilePath : resolveModulePath;
      return resolver(path, baseDir);
    };
    return this.require = function(path, baseDir) {
      var baseDirParts, module, require, resolvedPath;
      if (baseDir == null) baseDir = '.';
      resolvedPath = resolve(path, baseDir);
      baseDirParts = resolvedPath.split('/');
      baseDirParts.pop();
      baseDir = baseDirParts.join('/') || null;
      if (cache[resolvedPath]) return cache[resolvedPath].exports;
      module = cache[resolvedPath] = {
        exports: {}
      };
      require = function(newPath) {
        return _this.require(newPath, baseDir);
      };
      sourceFiles[resolvedPath](module.exports, require, module);
      return module.exports;
    };
  }).call(this);

}).call(this);
