Janitor = require 'janitor'
Package = require '../lib/browser-bundler/package'
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
  
  'test number of dependending packages with nested dependencies': ->
    root_dir = path.join __dirname, 'fixtures', 'nested-dependencies-package'
    package = new Package root_dir
    @assertEqual 1, package.packages().length
  
  'test finding package files': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    package = new Package root_dir
    @assertEqual 2, package.packageFiles().length
    @assertContains package.packageFiles(), 'package.json'
    @assertContains package.packageFiles(), 'node_modules/funky_rocket/package.json'
  
  'test finding package files in package without any package files': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package root_dir
    @assertEqual 0, package.packageFiles().length
  
  'test finding package files with nested dependencies': ->
    root_dir = path.join __dirname, 'fixtures', 'nested-dependencies-package'
    package = new Package root_dir
    @assertEqual 3, package.packageFiles().length
    @assertContains package.packageFiles(), 'package.json'
    @assertContains package.packageFiles(), 'node_modules/car/package.json'
    @assertContains package.packageFiles(), 'node_modules/car/node_modules/wheel/package.json'
  
  'test finding source files': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    package = new Package root_dir
    @assertEqual 3, package.sourceFiles().length
    @assertContains package.sourceFiles(), 'main.js'
    @assertContains package.sourceFiles(), 'lib/child1.js'
    @assertContains package.sourceFiles(), 'lib/child2.js'
  
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
