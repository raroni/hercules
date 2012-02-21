glob = require 'glob'
path = require 'path'
fs = require 'fs'
Package = require "./package"

module.exports = class Bundle
  constructor: (@root_dir) ->
    @package = new Package @root_dir
  
  readFile: (file) ->
    fs.readFileSync path.join(@root_dir, file), 'utf-8'
  
  sourceFilesAsJSON: ->
    output = "{"
    index = 0
    for file in @package.sourceFiles()
      contents = @readFile file
      output += ", " if index++ != 0
      output += JSON.stringify file.replace('.js', '')
      output += ':'
      output += "function(exports, require, module) { #{contents} }"
    output += "}"
  
  packageFilesAsJSON: ->
    map = {}
    for file in @package.packageFiles()
      contents = @readFile file
      map[file] = JSON.parse contents
    JSON.stringify map
  
  toString: ->
    client_path = path.join __dirname, 'client.js'
    client_js = fs.readFileSync client_path, 'utf-8'
    client_js = client_js.replace "'[[[source_files]]]'", @sourceFilesAsJSON()
    client_js = client_js.replace "'[[[package_files]]]'", @packageFilesAsJSON()
    client_js
