Janitor = require 'janitor'
SourceFileHandler = require '../lib/browser-bundler/source_file_handler'
path = require 'path'

module.exports = class SourceFileHandlerTest extends Janitor.TestCase
  'test finding files': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new SourceFileHandler root_dir
    @assertEqual 3, bundle.files().length
    @assertContains bundle.files(), 'main.js'
    @assertContains bundle.files(), 'lib/child1.js'
    @assertContains bundle.files(), 'lib/child2.js'
