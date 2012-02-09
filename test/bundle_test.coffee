Janitor = require 'janitor'
Bundle = require '../src/lib/bundle'
path = require 'path'

module.exports = class BundleTest extends Janitor.TestCase
  'test finding files': ->
    dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle dir
    @assertEqual 3, bundle.files().length
    @assertContains bundle.files(), 'main.js'
    @assertContains bundle.files(), 'lib/child1.js'
    @assertContains bundle.files(), 'lib/child2.js'

  'test bundle defining require': ->
    dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    @assert context.require
    @assertEqual 'function', typeof(context.require)
  
  'test simple require': ->
    dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Rasmus', main.name
  
  'test chained require': ->
    dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Child 1', main.child1.name
  
  'test caching': ->
    dir = path.join __dirname, 'fixtures', 'simple-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    new_name = main.child1.name += 'a'
    main = context.require './main'
    @assertEqual new_name, main.child1.name
  
  'test relative': ->
    dir = path.join __dirname, 'fixtures', 'relative-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    child = context.require './children/child1'
    @assertEqual 'Parent', child.parent.name
    @assertEqual 'Child 2', child.sibling.name
  
  'test cycling dependencies': ->
    dir = path.join __dirname, 'fixtures', 'circular-package'
    bundle = new Bundle dir
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
    dir = path.join __dirname, 'fixtures', 'using-module-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './main'
    @assertEqual 'Rasmus', main.name
