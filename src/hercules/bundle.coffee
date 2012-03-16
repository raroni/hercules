glob = require 'glob'
path = require 'path'
fs = require 'fs'
Package = require "./package"

module.exports = class Bundle
  constructor: (@root_dir, @options) ->
    @package = new Package @root_dir
  
  sourceFilesAsJSON: ->
    files = (
      for file in @package.sourceFiles()
        contents = fs.readFileSync path.join(@root_dir, file), 'utf-8'
        "'#{file.replace('.js', '')}': function(exports, require, module) { #{contents} }"
    )
    "{ #{files.join()} }"
  
  packageFilesAsJSON: ->
    map = {}
    map['package.json'] = @package.metaData() if @package.metaData()
    for package in @package.packages()
      throw new Error 'Cannot bundle packages that require node.js' if !@options?.ignore_node_packages && package.requiresNode()
      map[@stripRootDir(package.metaDataFile())] = package.metaData() unless package.requiresNode()
    JSON.stringify map
  
  toString: ->
    client_path = path.join __dirname, 'client.js'
    client_js = fs.readFileSync client_path, 'utf-8'
    client_js = client_js.replace "'[[source_files]]'", @sourceFilesAsJSON().replace(/\$/g, "$$$$")
    client_js.replace "'[[package_files]]'", @packageFilesAsJSON()
  
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
