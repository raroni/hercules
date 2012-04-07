glob = require 'glob'
path = require 'path'
fs = require 'fs'
Package = require "./package"

module.exports = class Bundle
  constructor: (@rootDir, @options) ->
    @package = new Package @rootDir
  
  sourceFilesAsJSON: ->
    files = (
      for file in @package.sourceFiles()
        contents = fs.readFileSync path.join(@rootDir, file), 'utf-8'
        "'#{file}': function(exports, require, module) { #{contents} }"
    )
    "{ #{files.join()} }"
  
  packageFilesAsJSON: ->
    map = {}
    map['package.json'] = @package.metaData() if @package.metaData()
    for package in @package.packages()
      throw new Error 'Cannot bundle packages that require node.js' if !@options?.ignoreNodePackages && package.requiresNode()
      map[@stripRootDir(package.metaDataFile())] = package.metaData() unless package.requiresNode()
    JSON.stringify map
  
  toString: ->
    clientPath = path.join __dirname, 'client.js'
    clientJs = fs.readFileSync clientPath, 'utf-8'
    clientJs = clientJs.replace "'[[sourceFiles]]'", @sourceFilesAsJSON().replace(/\$/g, "$$$$")
    clientJs.replace "'[[packageFiles]]'", @packageFilesAsJSON()
  
  stripRootDir: (path) =>
    path.replace(@rootDir, '').substring(1)
