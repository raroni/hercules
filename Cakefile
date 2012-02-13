{print} = require 'util'
{spawn} = require 'child_process'

build = (callback) ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', callback

task 'test', 'Run test suite', ->
  build ->
    Janitor = require 'janitor'
    runner = new Janitor.NodeRunner { dir: __dirname + '/test' }
    runner.run()
