glob = require 'glob'
path = require 'path'

module.exports = class Bundle
  constructor: (@dir) ->
  
  files: ->
    @_files ||= (
      glob_search_string = path.join @dir, '**.**'
      files = glob.sync glob_search_string
      files.filter @shouldBeIncluded
    )
  
  shouldBeIncluded: (file) =>
    ext = path.extname(file).substring(1)
    ext == 'js' || @isCompilable ext
  
  isCompilable: (extension) ->
    # TODO: Make smarter by actually looking at what compilers are present.
    extension == 'coffee'
  
  compile: ->
    console.log 'I cannot compile yet :('
  
  toString: ->
    '(function() {})();'
