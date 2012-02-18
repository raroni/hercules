Janitor = require 'janitor'
Bundle = require '../lib/browser-bundler/bundle'
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
  
  'test chained require': ->
    root_dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle root_dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Child 1', main.child1.name
  
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
    @assertThrows (-> context.require 'none-existing'), ((e) -> e.message == "Cannot find module 'none-existing'")
  
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
