(->
  source_files = '[[[source_files]]]'
  package_files = '[[[package_files]]]'
  cache = {}
  
  resolveFilePath = (path, base_dir) ->
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
  
  resolveModulePath = (module_name, base_dir) ->
    index = 0
    while !package
      base_dir = base_dir.split('/').slice(0, -1).join '/' unless index++ == 0
      package_dir = resolveFilePath base_dir + '/node_modules/' + module_name
      package_file = package_dir + '/package.json'
      package = package_files[package_file]
      throw new Error 'Module not found.' if !package && base_dir == '.'
    resolveFilePath(package_dir + '/' + package.main)
  
  resolvePath = (path, base_dir) ->
    base_dir ||= '.'
    if path.substring(0, 1) == '.'
      resolveFilePath path, base_dir
    else
      resolveModulePath path, base_dir
  
  context.require = (path, base_dir) ->
    resolved_path = resolvePath path, base_dir
    return cache[resolved_path].exports if cache[resolved_path]
    module = cache[resolved_path] = exports: {}
    base_dir = path.split('/').slice(0, -1).join('/')
    require = (new_path) -> context.require new_path, base_dir
    source_files[resolved_path] module.exports, require, module
    module.exports
)(this)
