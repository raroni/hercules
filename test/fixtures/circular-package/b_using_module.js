var A = require("./a_using_module");

module.exports = {
  a: function() {
    return A.a();
  }
};
