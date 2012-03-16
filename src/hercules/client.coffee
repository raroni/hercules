(->
  source_files = '[[source_files]]'
  package_files = '[[package_files]]'
  cache = {}
    
  resolvePath = (path, base_dir) ->
    full_path = if base_dir
      [base_dir, path].join '/'
    else
      path
    
    parts = full_path.split '/'
    result = []
    
    for part in parts
      if part == '..'
        result.pop()
      else if part != '.'
        result.push part
    
    [result.join('/'), path.split('/').slice(0, -1).join('/')]
  
  resolveFilePath = (path, base_dir) ->
    path += '.js' unless path.match ///\.js$///
    resolvePath path, base_dir
  
  resolveModulePath = (module_name, base_dir) ->
    index = 0
    while !package
      base_dir = base_dir.split('/').slice(0, -1).join '/' unless index++ == 0
      package_dir = resolvePath(base_dir + '/node_modules/' + module_name)[0]
      package_file = package_dir + '/package.json'
      package = package_files[package_file]
      throw new Error "Cannot find module '#{module_name}'" if !package && base_dir == '.'
    [resolveFilePath(package_dir + '/' + package.main)[0], package_dir]
  
  resolve = (path, base_dir) ->
    resolver = if path.substring(0, 1) == '.' then resolveFilePath else resolveModulePath
    resolver path, base_dir
  
  this.require = (path, base_dir) =>
    base_dir ||= '.'
    [resolved_path, base_dir] = resolve path, base_dir
    # kan man ikke bare udregne base_dir ved at fjerne sidste led i resolved_path
    
    return cache[resolved_path].exports if cache[resolved_path]
    module = cache[resolved_path] = exports: {}
    
    require = (new_path) => this.require new_path, base_dir
    source_files[resolved_path] module.exports, require, module
    module.exports
).call(this)
