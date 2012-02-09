var a = require("./a_using_exports");
exports.a = function() {
  return a.a();
};
