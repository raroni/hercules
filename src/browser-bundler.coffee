Bundle = require './browser-bundler/bundle'

exports.bundle = (path, options) -> new Bundle path, options
