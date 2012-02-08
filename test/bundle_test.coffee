Janitor = require 'janitor'
Bundle = require '../src/lib/bundle'
path = require 'path'

module.exports = class BundleTest extends Janitor.TestCase
  'test finding files': ->
    dir = path.join __dirname, 'fixtures', 'sample-package'
    bundle = new Bundle dir
    @assertEqual 2, bundle.files().length
    @assertContains bundle.files(), 'main.js'
    @assertContains bundle.files(), 'lib/secondary.js'

  'test bundle defining require': ->
    dir = path.join __dirname, 'fixtures', 'sample-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    @assert context.require
    @assertEqual 'function', typeof(context.require)
