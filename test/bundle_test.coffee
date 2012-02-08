Janitor = require 'janitor'
Bundle = require '../src/lib/bundle'
path = require 'path'

module.exports = class BundleTest extends Janitor.TestCase
  'test compile': ->
    dir = path.join __dirname, 'fixtures', 'sample-package'
    bundle = new Bundle dir
    @assertEqual 1, bundle.files().length

    