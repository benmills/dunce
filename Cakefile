{spawn, exec} = require 'child_process'
print = console.log

task 'build', 'Compile CoffeeScript source files', ->
  options = ['-c', '-o', 'lib', 'src']

  coffee = spawn 'coffee', options
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()
  coffee.on 'exit', (status) -> 
    if status is 0
      exec("mv lib/dunce.js lib/dunce")
