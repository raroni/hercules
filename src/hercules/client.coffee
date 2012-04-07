(->
  sourceFiles = '[[sourceFiles]]'
  packageFiles = '[[packageFiles]]'
  cache = {}
    
  resolvePath = (path, baseDir) ->
    fullPath = if baseDir
      [baseDir, path].join '/'
    else
      path
    
    parts = fullPath.split '/'
    result = []
    
    for part in parts
      if part == '..'
        result.pop()
      else if part != '.'
        result.push part
    
    result.join '/'
  
  resolveFilePath = (path, baseDir) ->
    path += '.js' unless path.match ///\.js$///
    resolvePath path, baseDir
  
  resolveModulePath = (moduleName, baseDir) ->
    index = 0
    while !package
      baseDir = baseDir.split('/').slice(0, -1).join '/' unless index++ == 0
      packageDir = resolvePath('node_modules/' + moduleName, baseDir)
      packageFile = packageDir + '/package.json'
      package = packageFiles[packageFile]
      throw new Error "Cannot find module '#{moduleName}'" if !package && !baseDir
    
    packageMainPath = [packageDir, package.main].join '/'
    resolveFilePath packageMainPath
  
  resolve = (path, baseDir) ->
    resolver = if path.substring(0, 1) == '.' then resolveFilePath else resolveModulePath
    resolver path, baseDir
  
  this.require = (path, baseDir = '.') =>
    resolvedPath = resolve path, baseDir
    
    baseDirParts = resolvedPath.split '/'
    baseDirParts.pop()
    baseDir = baseDirParts.join('/') || null
    
    return cache[resolvedPath].exports if cache[resolvedPath]
    module = cache[resolvedPath] = exports: {}
    
    require = (newPath) => this.require newPath, baseDir
    sourceFiles[resolvedPath] module.exports, require, module
    module.exports
).call(this)
