Janitor = require 'janitor'
Bundle = require '../lib/hercules/bundle'
path = require 'path'

module.exports = class BundleTest extends Janitor.TestCase
  'test bundle defining require': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    @assert context.require
    @assertEqual 'function', typeof(context.require)
  
  'test simple require': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Rasmus', main.name
    main = context.require './main.js'
    @assertEqual 'Rasmus', main.name
  
  'test chained require': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Child 3', main.child1.child2.child3.name
  
  'test caching': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    new_name = main.child1.name += 'a'
    main = context.require './main'
    @assertEqual new_name, main.child1.name
  
  'test relative': ->
    root_dir = path.join __dirname, 'fixtures', 'relative-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    child = context.require './children/child1'
    @assertEqual 'Parent', child.parent.name
    @assertEqual 'Child 2', child.sibling.name
  
  'test cycling dependencies': ->
    root_dir = path.join __dirname, 'fixtures', 'circular-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    a = context.require './a_using_exports'
    b = context.require './b_using_exports'
    @assertEqual 'a', b.a()
    @assertEqual 'a', a.b.a()
    
    a = context.require './a_using_module'
    b = context.require './b_using_module'
    @assertEqual 'a', b.a()
    @assertEqual 'a', a.b().a()
  
  'test using module as export method': ->
    root_dir = path.join __dirname, 'fixtures', 'using-module-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Rasmus', main.name
  
  'test loading dependency inside main package': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'FUNKY ROCKET!', main.funky_rocket_name
  
  'test dependency directly': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    funky_rocket = context.require 'funky_rocket'
    @assertEqual 'FUNKY ROCKET!', funky_rocket.name
  
  'test loading non existing dependency': ->
    root_dir = path.join __dirname, 'fixtures', 'dependency-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    procedure = -> context.require 'none-existing'
    @assertThrows (e) -> e.message == "Cannot find module 'none-existing'"
  
  'test loading dependency from parent dir': ->
    root_dir = path.join __dirname, 'fixtures', 'parent-dependency-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './lib/tester'
    @assertEqual 'TUTTI FRUTTI', main.tutti_frutti_name
  
  "test loading dependency's dependency": ->
    root_dir = path.join __dirname, 'fixtures', 'nested-dependencies-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'round', main.car.wheel.shape
  
  'test loading package depending on nodejs package': ->
    root_dir = path.join __dirname, 'fixtures', 'node-dependency-package'
    bundle = new Bundle root_dir
    procedure = -> bundle.toString()
    @assertThrows procedure, (e) -> e.message == "Cannot bundle packages that require node.js"
  
  'test ignoring node packages': ->
    root_dir = path.join __dirname, 'fixtures', 'node-dependency-package'
    bundle = new Bundle root_dir, ignore_node_packages: true
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    @assert context.require('./main')
    
    procedure = -> context.require('fancy-fs')
    @assertThrows procedure, (e) -> e.message == "Cannot find module 'fancy-fs'"
  
  'test package containing code with dollar sign followed by apostrophe': ->
    # As detailed on the page below, String#replace acts special for strings with $'
    # https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_string_as_a_parameter
    
    root_dir = path.join __dirname, 'fixtures', 'dollar-sign-apostrophe-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Rasmus', main.name
