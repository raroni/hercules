Janitor = require 'janitor'
BrowserBundler = require '../.'
path = require 'path'

module.exports = class BundleTest extends Janitor.TestCase
  'test bundling': ->
    bundle_path = path.join __dirname, 'fixtures', 'simple-package'
    bundle = BrowserBundler.bundle bundle_path
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Rasmus', main.name
