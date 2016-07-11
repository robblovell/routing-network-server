var should = require('should');

should.wrap = function(obj) {
  return new should.Assertion(obj);
}

/**
 * Enable .should.be.anArray();
 * @param {string} desc
 * @api public
 */
should.Assertion.prototype.endWith = function(desc){
  // NOTE(gregp): broken in IE6? meh
  var type = 'array';
  this.assert(
      this.isArray_()
    , function(){ return 'expected ' + this.inspect + ' to be a ' + type + (desc ? " | " + desc : "") }
    , function(){ return 'expected ' + this.inspect + ' not to be a ' + type  + (desc ? " | " + desc : "") });
  return this;
};

/**
 * Return whether the object is an array.
 *
 * @return {boolean}
 * @api private
 */
should.Assertion.prototype.isArray_ = function(){
  return ('object' == typeof this.obj) &&
         ('[object Array]' == Object.prototype.toString.call(this.obj));
         // no IE6
};

/**
 * Check that the given string matches at the end of the current object.
 *
 * @param {string} str
 * @api public
 */
should.Assertion.prototype.endWith = function(str) {
  this.obj.should.match(new RegExp(str + '$'))
  return this;
};

/**
 * Check that each of the given string keys,
 *  when converted to regexes, matches the current object in
 *
 * @param {Object.<string, number>} expected
 * @param {string} desc
 * @api public
 */
should.Assertion.prototype.matchSet = function(expected, desc) {
  var keys = Object.keys(expected);
  var regexes = {};
  var remaining = {};
  keys.forEach(function(re) {
    regexes[re] = new RegExp(re);
    remaining[re] = expected[re];
  });

  this.obj.should.be.a('object');
  var obj;
  if (this.isArray_()) {
    obj = this.obj;
  } else {
    obj = Object.keys(this.obj);
  }

  // Really, should be an array of strings.
  // TODO(gregp): code ^^^^^^^^^^^^^^^^^^^ that would be a good should.
  obj.should.have.property('length');
  obj.should.have.property('forEach');

  // Context description to print
  var descStr = (desc ? (' in ' + desc) : '');

  // Check each item in the current object
  //  against each of our regexes remaining
  obj.forEach(function(cur) {
    cur.should.be.a('string',
      'an element' + descStr + ' was not a string');
    keys.forEach(function(key) {
      // key must be a string by the contract of Object.keys
      if (regexes[key].exec(cur)) {
        --remaining[key];
      }
    });
  });

  // TODO(gregp): This should build up a mapping of the expected vs. found
  //  values for each element/key, then assert all at once that each are 0
  // Inversion doesn't make much sense in the current state....

  // Ensure that we had exactly the number of matches expected
  keys.forEach(function(key) {
    var msg = function(invert) {
      var inversion = (invert ? 'other than ' : '');
      var result =
        'incorrect number of occurrances ' +
        'of ' + key + descStr + ': ' +
        'expected ' + inversion + expected[key] + ', ' +
        'found ' + (expected[key] - remaining[key]) + '.';
      return result;
    };

    this.assert(
      remaining[key] === 0,
      msg.bind(this, false),
      msg.bind(this, true)
      );
  }.bind(this));

  return this;
};

/**
 * Checks that the current object should match the given regex
 *  at n different starting indices.
 *
 * Note that this is not always equivalent to the number of matches,
 *  for instance, /.*_/ will only match 3 times in a_b_c_:
 *    a_, b_, c_,
 *  whereas it should technically match 6 times:
 *    a_, a_b_, a_b_c_, b_, b_c_, c_
 * This should hopefully not be a problem for real-world use.
 *
 * @param {RegExp|string} regex
 * @param {number} n
 * @api public
 */
should.Assertion.prototype.matchN = function(regex, n) {
  if (typeof regex == 'string') {
    regex = new RegExp(regex);
  }
  regex.global = true;

  this.obj.should.be.a('string');
  var val = this.obj.slice();

  var count = 0;
  var result;
  while(result = regex.exec(val)) {
    val = val.slice(result.index + 1);
    ++count;
  }
  count.should.equal(n);
};

/**
 * Check that each of the given items are contained in the current object.
 *
 * @param {Array.<*>} items
 * @api public
 */
should.Assertion.prototype.containEach = function(items) {
  items.should.be.a('object');
  items.should.have.property('length');
  items.should.have.property('forEach');
  items.forEach(function(item) {
    this.obj.should.include(item);
  }, this);
};

module.exports = should;
