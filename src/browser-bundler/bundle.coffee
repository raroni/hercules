glob = require 'glob'
path = require 'path'
fs = require 'fs'
PackageHandler = require "./package_handler"

module.exports = class Bundle
  constructor: (@root_dir) ->
    @packages = new PackageHandler @root_dir
  
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
  
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
  
  fileMapAsJSONString: ->
    output = "{"
    index = 0
    for path, contents of @sourceFileMap()
      output += ", " if index++ != 0
      output += JSON.stringify path
      output += ':'
      output += "function(exports, require, module) { #{contents} }"
    output += "}"
  
  toString: ->
    client_path = path.join __dirname, 'client.js'
    client_js = fs.readFileSync client_path, 'utf-8'
    client_js = client_js.replace "'[[[source_files]]]'", @fileMapAsJSONString()
    client_js = client_js.replace "'[[[package_files]]]'", JSON.stringify(@packages.map())
    client_js
