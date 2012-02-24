(function() {
  var Bundle;

  Bundle = require('./hercules/bundle');

  exports.bundle = function(path, options) {
    return new Bundle(path, options);
  };

}).call(this);
