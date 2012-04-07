Janitor = require 'janitor'
Package = require '../lib/hercules/package'
path = require 'path'

module.exports = class PackageTest extends Janitor.TestCase
  'test number of dependending packages': ->
    rootDir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package rootDir
    @assertEqual 1, package.packages().length
  
  'test number of dependending packages for package with several depending packages': ->
    rootDir = path.join __dirname, 'fixtures', 'several-dependencies-package'
    package = new Package rootDir
    @assertEqual 2, package.packages().length
  
  'test finding packages': ->
    rootDir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package rootDir
    @assertEqual 1, package.packages().length
    @assertEqual package.packages()[0].metaData().name, 'funky-rocket'
  
  'test finding packages in package with no dependencies': ->
    rootDir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package rootDir
    @assertEqual 0, package.packages().length
  
  'test finding package files with nested dependencies': ->
    rootDir = path.join __dirname, 'fixtures', 'nested-dependencies-package'
    package = new Package rootDir
    @assertEqual 2, package.packages().length
    meta_data_names = package.packages().map (p) -> p.metaData().name
    @assertContains meta_data_names, 'car'
    @assertContains meta_data_names, 'wheel'
  
  'test finding source files': ->
    rootDir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package rootDir
    @assertEqual 4, package.sourceFiles().length
    @assertContains package.sourceFiles(), 'main.js'
    @assertContains package.sourceFiles(), 'lib/child1.js'
    @assertContains package.sourceFiles(), 'lib/child2.js'
    @assertContains package.sourceFiles(), 'lib/child3.js'
  
  'test finding source files of package with dependencies': ->
    rootDir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package rootDir
    @assertEqual 2, package.sourceFiles().length
    @assertContains package.sourceFiles(), 'main.js'
    @assertContains package.sourceFiles(), 'node_modules/funky_rocket/main.js'
  
  'test finding source files of package with several dependencies': ->
    rootDir = path.join __dirname, 'fixtures', 'several-dependencies-package'
    package = new Package rootDir
    @assertEqual 3, package.sourceFiles().length
    @assertContains package.sourceFiles(), 'main.js'
    @assertContains package.sourceFiles(), 'node_modules/churanimo/main.js'
    @assertContains package.sourceFiles(), 'node_modules/cowabunga/my_main.js'
  
  'test meta data': ->
    rootDir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package rootDir
    @assertEqual 'dependecy-test-package', package.metaData().name
    @assertEqual '0.0.1', package.metaData().version
  
  'test meta data for package without package file': ->
    rootDir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package rootDir
    @assert !package.metaData()
  
  'test requires node': ->
    rootDir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package rootDir
    @assert !package.requiresNode()
    
    rootDir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package rootDir
    @assert !package.requiresNode()
    
    rootDir = path.join __dirname, 'fixtures', 'node-package'
    package = new Package rootDir
    @assert package.requiresNode()
