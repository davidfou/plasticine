  sinon.noConflict = function() {
    root.sinon = previousSinon;
    return this;
  }
  define(function() {return sinon.noConflict();});
}).call(this);
