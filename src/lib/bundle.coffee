glob = require 'glob'
path = require 'path'
fs = require 'fs'

module.exports = class Bundle
  constructor: (@root_dir) ->
  
  sourceFiles: ->
    @_source_files ||= @buildSourceFileList()
    
  buildSourceFileList: ->
    glob_search_string = path.join @root_dir, '**.**'
    files = glob.sync glob_search_string
    files = files.filter @sourceFileShouldBeIncluded
    files.map @stripRootDir
  
  sourceFileShouldBeIncluded: (file) =>
    ext = path.extname(file).substring(1)
    ext == 'js' || @isCompilable ext
  
  isCompilable: (extension) ->
    # TODO: Make smarter by actually looking at what compilers are present.
    extension == 'coffee'
  
  sourceFileMap: ->
    map = {}
    for file in @sourceFiles()
      file_path = path.join @root_dir, file
      map[file.replace('.js', '')] = fs.readFileSync file_path, 'utf-8'
    map
  
  packageFiles: ->
    @_package_files ||= @buildPackageFileList()
  
  buildPackageFileList: ->
    glob_search_string = path.join @root_dir, '**package.json'
    files = glob.sync glob_search_string
    files.map @stripRootDir
  
  packageFileMap: ->
    map = {}
    for file in @packageFiles()
      file_path = path.join @root_dir, file
      content = fs.readFileSync file_path, 'utf-8'
      map[file] = JSON.parse content
    map
  
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
  
  toString: ->
    # Todo: Move this out into own method
    source_files = "{"
    index = 0
    for path, contents of @sourceFileMap()
      source_files += ", " if index++ != 0
      source_files += JSON.stringify path
      source_files += ':'
      source_files += "function(exports, require, module) { #{contents} }"
    source_files += "}"
    
    # Todo: Convert this to Coffeescript somehow?
    """
      (function(context) {
        var source_files = #{source_files};
        var package_files = #{JSON.stringify(@packageFileMap())};
        var cache = {};
        
        var resolveFilePath = function(path, base_dir) {
          var full_path;
          if(base_dir) {
             full_path = [base_dir, path].join('/');
          } else {
            full_path = path;
          }
            
          var parts = full_path.split('/'), result = [], part;
          
          for(var i=0; parts.length>i; i++) {
            part = parts[i];
            if(part == '..') {
              result.pop();
            } else if(part != '.') {
              result.push(part);
            }
          }
          return result.join('/');
        };
        
        var resolveModulePath = function(module_name, base_dir) {
          var package_dir = resolveFilePath(base_dir + '/node_modules/' + module_name);
          var package_file = package_dir + '/package.json'
          var main_file = resolveFilePath(package_dir + '/' + package_files[package_file].main);
          return main_file;
        };
        
        var resolvePath = function(path, base_dir) {
          if(path.substring(0, 1) == '.') {
            return resolveFilePath(path, base_dir);
          } else {
            return resolveModulePath(path, base_dir);
          }
        };
        context.require = function(path, base_dir) {
          var resolved_path = resolvePath(path, base_dir);
          if(cache[resolved_path]) return cache[resolved_path].exports;
          
          var module = cache[resolved_path] = { exports: {} };
          
          var base_dir = path.split('/').slice(0, -1).join('/');
          var require = function(new_path) {
            return context.require(new_path, base_dir);
          };
          source_files[resolved_path](module.exports, require, module);
          return module.exports;
        };
        
      })(this);
    """
