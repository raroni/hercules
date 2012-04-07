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
    
    result.join '/'
  
  resolveFilePath = (path, base_dir) ->
    path += '.js' unless path.match ///\.js$///
    resolvePath path, base_dir
  
  resolveModulePath = (module_name, base_dir) ->
    index = 0
    while !package
      base_dir = base_dir.split('/').slice(0, -1).join '/' unless index++ == 0
      package_dir = resolvePath('node_modules/' + module_name, base_dir)
      package_file = package_dir + '/package.json'
      package = package_files[package_file]
      throw new Error "Cannot find module '#{module_name}'" if !package && !base_dir
    
    packageMainPath = [package_dir, package.main].join '/'
    resolveFilePath packageMainPath
  
  resolve = (path, base_dir) ->
    resolver = if path.substring(0, 1) == '.' then resolveFilePath else resolveModulePath
    resolver path, base_dir
  
  this.require = (path, base_dir = '.') =>
    resolved_path = resolve path, base_dir
    
    base_dir_parts = resolved_path.split '/'
    base_dir_parts.pop()
    base_dir = base_dir_parts.join('/') || null
    
    return cache[resolved_path].exports if cache[resolved_path]
    module = cache[resolved_path] = exports: {}
    
    require = (new_path) => this.require new_path, base_dir
    source_files[resolved_path] module.exports, require, module
    module.exports
).call(this)
