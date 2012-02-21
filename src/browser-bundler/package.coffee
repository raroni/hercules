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
    glob_search_string = path.join @root_dir, '**.**'
    files = glob.sync glob_search_string
    files = files.map (f) => @stripRootDir(f)
    files = files.filter @shouldBeIncluded
    
    for package in @packages()
      for file in package.sourceFiles()
        files.push path.join(@stripRootDir(package.root_dir), file)
    
    files
  
  shouldBeIncluded: (file) =>
    ext = path.extname(file).substring(1)
    ext == 'js' && file.indexOf('node_modules') != 0
  
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
  
  packages: ->
    @_packages ||= (
      packages = []
      glob_search_string = path.join @root_dir, '/node_modules/*/package.json'
      files = glob.sync glob_search_string
      for file in files
        package_path = path.dirname(file)
        package = new Package package_path
        packages.push package
        for sub_package in package.packages()
          packages.push sub_package
      packages
    )
