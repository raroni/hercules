glob = require 'glob'
path = require 'path'
fs = require 'fs'
PackageHandler = require "./package_handler"
SourceFileHandler = require "./source_file_handler"

module.exports = class Bundle
  constructor: (root_dir) ->
    @packages = new PackageHandler root_dir
    @source_files = new SourceFileHandler root_dir
  
  fileMapAsJSONString: ->
    output = "{"
    index = 0
    for path, contents of @source_files.map()
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
