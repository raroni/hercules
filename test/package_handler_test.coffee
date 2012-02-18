Janitor = require 'janitor'
PackageHandler = require '../lib/browser-bundler/package_handler'
path = require 'path'

module.exports = class PackageHandlerTest extends Janitor.TestCase
  'test finding package files': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    handler = new PackageHandler root_dir
    @assertEqual 2, handler.files().length
    @assertContains handler.files(), 'package.json'
    @assertContains handler.files(), 'node_modules/funky_rocket/package.json'
