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
    
    console.log(files)
    
    """
      (function(context) {
        var files = #{files};
        var resolvePath = function(path) {
          if(path.substring(0, 2) == './') {
            return path.substring(2);
          }
        };
        context.require = function(path) {
          path = resolvePath(path);
          var exports = {}
          files[path](exports, context.require, module);
          return exports;
        };
        
      })(this);
    """
