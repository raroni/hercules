(function() {
  var Bundle;

  Bundle = require('./browser-bundler/bundle');

  exports.bundle = function(path) {
    return new Bundle(path);
  };

}).call(this);
