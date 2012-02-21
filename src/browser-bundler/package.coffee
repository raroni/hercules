glob = require 'glob'
path = require 'path'
fs = require 'fs'

module.exports = class Package
  constructor: (@root_dir) ->
  
  metaData: ->
    return unless path.existsSync path.join(@root_dir, 'package.json')
    file = path.join @root_dir, 'package.json'
    contents = fs.readFileSync file, 'utf-8'
    JSON.parse contents
  
  sourceFiles: ->
    glob_search_string = path.join @root_dir, '**.**'
    files = glob.sync glob_search_string
    files = files.map (f) => @stripRootDir(f)
    files = files.filter @shouldBeIncluded
    
    for package in @packages()
      for file in package.sourceFiles()
        files.push path.join(@stripRootDir(package.root_dir), file)
    
    files
  
  packages: ->
    glob_search_string = path.join @root_dir, '/node_modules/*/package.json'
    files = glob.sync glob_search_string
    files.map (file) =>
      package_path = path.dirname(file)
      new Package package_path
  
  shouldBeIncluded: (file) =>
    ext = path.extname(file).substring(1)
    ext == 'js' && file.indexOf('node_modules') != 0
  
  stripRootDir: (path) =>
    path.replace(@root_dir, '').substring(1)
  
  packageFiles: ->
    @_blah ||= (
      files = []
      files.push 'package.json' if @metaData()
      for package in @packages()
        for package_file in package.packageFiles()
          package_path = path.join @stripRootDir(package.root_dir), package_file
          files.push package_path
      files
    )
