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
