(function() {
  var Bundle;

  Bundle = require('./browser-bundler/bundle');

  exports.bundle = function(path, options) {
    return new Bundle(path, options);
  };

}).call(this);
