module.exports = {
  a: function() {
    return "a";
  },
  b: function() {
    return B;
  }
};

B = require('./b_using_module');
