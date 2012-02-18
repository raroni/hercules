glob = require 'glob'
path = require 'path'
fs = require 'fs'

module.exports = class PackageHandler
  constructor: (@root_dir) ->
  
  files: ->
    @_files ||= @buildFileList()
  
  buildFileList: ->
    glob_search_string = path.join @root_dir, '**package.json'
    files = glob.sync glob_search_string
    files.map @stripRootDir
  
  map: ->
    map = {}
    for file in @files()
      file_path = path.join @root_dir, file
      content = fs.readFileSync file_path, 'utf-8'
      map[file] = JSON.parse content
    map
    
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
