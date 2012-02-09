glob = require 'glob'
path = require 'path'
fs = require 'fs'

module.exports = class Bundle
  constructor: (@dir) ->
  
  files: ->
    @_files ||= (
      glob_search_string = path.join @dir, '**.**'
      files = glob.sync glob_search_string
      files = files.filter @shouldBeIncluded
      files.map (file) => file.replace(@dir, '').substring(1)
    )
  
  shouldBeIncluded: (file) =>
    ext = path.extname(file).substring(1)
    ext == 'js' || @isCompilable ext
  
  isCompilable: (extension) ->
    # TODO: Make smarter by actually looking at what compilers are present.
    extension == 'coffee'
  
  fileMap: ->
    map = {}
    for file in @files()
      file_path = path.join @dir, file
      map[file.replace('.js', '')] = fs.readFileSync file_path, 'utf-8'
    map
  
  toString: ->
    files = "{"
    index = 0
    for path, contents of @fileMap()
      files += ", " if index++ != 0
      files += JSON.stringify path
      files += ':'
      files += "function(exports, require, module) { #{contents} }"
    files += "}"
    
    """
      (function(context) {
        var files = #{files};
        var cache = {};
        var resolvePath = function(path) {
          var parts = path.split('/'), result = [], part;
          
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
        context.require = function(path) {
          var resolved_path = resolvePath(path);
          if(cache[resolved_path]) return cache[resolved_path];
          
          var exports = cache[resolved_path] = {};
          
          var base_dir = path.split('/').slice(0, path.split('/').length-1).join('/');
          var require = function(new_path) {
            full_path = [base_dir, new_path].join('/');
            return context.require(full_path);
          };
          files[resolved_path](exports, require, module);
          return exports;
        };
        
      })(this);
    """
