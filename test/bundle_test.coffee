Janitor = require 'janitor'
Bundle = require '../src/lib/bundle'
path = require 'path'

module.exports = class BundleTest extends Janitor.TestCase
  'test finding files': ->
    dir = path.join __dirname, 'fixtures', 'sample-package'
    bundle = new Bundle dir
    @assertEqual 3, bundle.files().length
    @assertContains bundle.files(), 'simple.js'
    @assertContains bundle.files(), 'advanced.js'
    @assertContains bundle.files(), 'advanced/sub.js'

  'test bundle defining require': ->
    dir = path.join __dirname, 'fixtures', 'sample-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    @assert context.require
    @assertEqual 'function', typeof(context.require)
  
  'test simple require': ->
    dir = path.join __dirname, 'fixtures', 'sample-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    main = context.require './simple'
    @assertEqual 'Rasmus', main.name

  'test chained require': ->
    dir = path.join __dirname, 'fixtures', 'sample-package'
    bundle = new Bundle dir
    result_in_closure = -> eval bundle.toString()
    result_in_closure.call context = {}
    advanced = context.require './advanced'
    @assertEqual 'Rasmus', advanced.secondary.name
