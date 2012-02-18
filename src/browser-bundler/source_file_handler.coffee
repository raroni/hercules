glob = require 'glob'
path = require 'path'
fs = require 'fs'

module.exports = class SourceFileHandler
  constructor: (@root_dir) ->
  
  files: ->
    @_list ||= @buildList()
  
  buildList: ->
    glob_search_string = path.join @root_dir, '**.**'
    files = glob.sync glob_search_string
    files = files.filter @shouldBeIncluded
    files.map @stripRootDir
  
  shouldBeIncluded: (file) =>
    ext = path.extname(file).substring(1)
    ext == 'js' || @isCompilable ext
  
  isCompilable: (extension) ->
    # TODO: Make smarter by actually looking at what compilers are present.
    extension == 'coffee'
  
  map: ->
    map = {}
    for file in @files()
      file_path = path.join @root_dir, file
      map[file.replace('.js', '')] = fs.readFileSync file_path, 'utf-8'
    map
  
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
