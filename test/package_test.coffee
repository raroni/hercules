Janitor = require 'janitor'
Package = require '../lib/hercules/package'
path = require 'path'

module.exports = class PackageTest extends Janitor.TestCase
  'test number of dependending packages': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package root_dir
    @assertEqual 1, package.packages().length
  
  'test number of dependending packages for package with several depending packages': ->
    root_dir = path.join __dirname, 'fixtures', 'several-dependencies-package'
    package = new Package root_dir
    @assertEqual 2, package.packages().length
  
  'test finding packages': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package root_dir
    @assertEqual 1, package.packages().length
    @assertEqual package.packages()[0].metaData().name, 'funky-rocket'
  
  'test finding packages in package with no dependencies': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package root_dir
    @assertEqual 0, package.packages().length
  
  'test finding package files with nested dependencies': ->
    root_dir = path.join __dirname, 'fixtures', 'nested-dependencies-package'
    package = new Package root_dir
    @assertEqual 2, package.packages().length
    meta_data_names = package.packages().map (p) -> p.metaData().name
    @assertContains meta_data_names, 'car'
    @assertContains meta_data_names, 'wheel'
  
  'test finding source files': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package root_dir
    @assertEqual 4, package.sourceFiles().length
    @assertContains package.sourceFiles(), 'main.js'
    @assertContains package.sourceFiles(), 'lib/child1.js'
    @assertContains package.sourceFiles(), 'lib/child2.js'
    @assertContains package.sourceFiles(), 'lib/child3.js'
  
  'test finding source files of package with dependencies': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package root_dir
    @assertEqual 2, package.sourceFiles().length
    @assertContains package.sourceFiles(), 'main.js'
    @assertContains package.sourceFiles(), 'node_modules/funky_rocket/main.js'
  
  'test finding source files of package with several dependencies': ->
    root_dir = path.join __dirname, 'fixtures', 'several-dependencies-package'
    package = new Package root_dir
    @assertEqual 3, package.sourceFiles().length
    @assertContains package.sourceFiles(), 'main.js'
    @assertContains package.sourceFiles(), 'node_modules/churanimo/main.js'
    @assertContains package.sourceFiles(), 'node_modules/cowabunga/my_main.js'
  
  'test meta data': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package root_dir
    @assertEqual 'dependecy-test-package', package.metaData().name
    @assertEqual '0.0.1', package.metaData().version
  
  'test meta data for package without package file': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package root_dir
    @assert !package.metaData()
  
  'test requires node': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package root_dir
    @assert !package.requiresNode()
    
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package root_dir
    @assert !package.requiresNode()
    
    root_dir = path.join __dirname, 'fixtures', 'node-package'
    package = new Package root_dir
    @assert package.requiresNode()
