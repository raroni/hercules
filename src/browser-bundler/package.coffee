glob = require 'glob'
path = require 'path'
fs = require 'fs'

module.exports = class Package
  constructor: (@root_dir) ->
  
  metaData: ->
    return unless path.existsSync @metaDataFile()
    contents = fs.readFileSync @metaDataFile(), 'utf-8'
    JSON.parse contents
  
  metaDataFile: ->
    path.join @root_dir, 'package.json'
  
  sourceFiles: ->
    glob_search_string = path.join @root_dir, '**.js'
    files = glob.sync glob_search_string
    files = files.map (f) => @stripRootDir(f)
    files = files.filter (file) -> file.indexOf('node_modules') != 0
    for package in @packages()
      for file in package.sourceFiles()
        files.push path.join(@stripRootDir(package.root_dir), file)
    
    files
  
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
  
  packages: ->
    @_packages ||= @buildPackages()
  
  buildPackages: ->
    packages = []
    glob_search_string = path.join @root_dir, '/node_modules/*/package.json'
    for file in glob.sync(glob_search_string)
      package = new Package path.dirname(file)
      packages.push package
      packages.push sub_package for sub_package in package.packages()
    packages
