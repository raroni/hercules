glob = require 'glob'
path = require 'path'
fs = require 'fs'

module.exports = class Package
  constructor: (@rootDir) ->
  
  metaData: ->
    return unless path.existsSync @metaDataFile()
    contents = fs.readFileSync @metaDataFile(), 'utf-8'
    JSON.parse contents
  
  metaDataFile: ->
    path.join @rootDir, 'package.json'
  
  sourceFiles: ->
    globSearchString = path.join @rootDir, '**.js'
    files = glob.sync globSearchString
    files = files.map (f) => @stripRootDir(f)
    files = files.filter (file) -> file.indexOf('node_modules') != 0
    for package in @packages()
      for file in package.sourceFiles()
        files.push path.join(@stripRootDir(package.rootDir), file)
    
    files
  
  stripRootDir: (path) =>
    path.replace(@rootDir, '').substring(1)
  
  packages: ->
    @_packages ||= @buildPackages()
  
  requiresNode: ->
    !!@metaData()?.engines?.node
  
  buildPackages: ->
    packages = []
    globSearchString = path.join @rootDir, '/node_modules/*/package.json'
    for file in glob.sync(globSearchString)
      package = new Package path.dirname(file)
      packages.push package
      packages.push subPackage for subPackage in package.packages()
    packages
