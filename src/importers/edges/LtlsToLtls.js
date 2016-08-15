// Generated by CoffeeScript 1.10.0
(function() {
  var Builder, Papa, async, fs, geodist, iImport, math, papaConfig,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  iImport = require('./../iImport');

  fs = require('fs');

  async = require('async');

  math = require('mathjs');

  geodist = require('geodist');

  fs = require('fs');

  Papa = require('babyparse');

  papaConfig = {
    delimiter: ",",
    newline: "",
    header: true,
    dynamicTyping: false,
    preview: 0,
    encoding: "UTF-8",
    worker: false,
    comments: false,
    step: void 0,
    download: false,
    skipEmptyLines: false,
    fastMode: false
  };

  Builder = (function(superClass) {
    extend(Builder, superClass);

    function Builder(config, repo1) {
      this.config = config;
      this.repo = repo1 != null ? repo1 : null;
      this.buildLtlToLtl = bind(this.buildLtlToLtl, this);
      this.traverseZips = bind(this.traverseZips, this);
      this.wireupLtlsToLtls = bind(this.wireupLtlsToLtls, this);
    }

    Builder.prototype.setRepo = function(repo) {
      return this.repo = repo;
    };

    Builder.prototype.wireupLtlsToLtls = function(aix, bix, zips, ltls, callback) {
      var distance, i, id1, id2, len, ltl, obj, params, zip1, zip2;
      zip1 = zips[aix];
      zip2 = zips[bix];
      this.repo.pipeline();
      if (zip1.zip3 !== '' && zip2 !== '') {
        for (i = 0, len = ltls.length; i < len; i++) {
          ltl = ltls[i];
          distance = geodist({
            lat: parseInt(zip1.latitude),
            lon: parseInt(zip1.longitude)
          }, {
            lat: parseInt(zip2.latitude),
            lon: parseInt(zip2.longitude)
          });
          if (distance < 1000) {
            id1 = zip1.zip3 + "_" + ltl.ltlCode + "_" + ltl.weightLo + "_" + ltl.weightHi;
            id2 = zip2.zip3 + "_" + ltl.ltlCode + "_" + ltl.weightLo + "_" + ltl.weightHi;
            params = {
              sourcekind: 'Ltl',
              sourceid: '' + id1,
              destinationkind: 'Ltl',
              destinationid: '' + id2,
              kind: 'LTL',
              cost: distance + 50,
              linkid: id1 + '_' + id2
            };
            obj = {
              kind: 'LTL',
              cost: distance + 50,
              id: id1 + "_" + id2
            };
            this.repo.setEdge(params, obj);
          }
        }
      }
      return this.repo.exec((function(_this) {
        return function(error, result) {
          if ((error != null)) {
            console.log("error:" + result);
            callback(error, result);
          } else if (bix + 1 < zips.length) {
            _this.wireupLtlsToLtls(aix, bix + 1, zips, ltls, callback);
          } else if (aix + 1 < zips.length) {
            console.log("zip: " + zips[aix].zip3);
            _this.traverseZips(aix + 1, 0, zips, ltls, callback);
          } else {
            callback(error, result);
          }
        };
      })(this));
    };

    Builder.prototype.traverseZips = function(aix, bix, zips, ltls, callback) {
      this.wireupLtlsToLtls(aix, bix, zips, ltls, callback);
    };

    Builder.prototype.buildLtlToLtl = function(callback) {
      var filename;
      filename = './data/weights-codes.csv';
      this.repo.find({
        type: "Zip"
      }, (function(_this) {
        return function(error, zips) {
          var contentsCodes, ltls, result;
          contentsCodes = fs.readFileSync(filename, 'utf8');
          result = Papa.parse(contentsCodes, papaConfig);
          ltls = result.data;
          _this.traverseZips(0, 0, zips, ltls, callback);
        };
      })(this));
    };

    return Builder;

  })(iImport);

  module.exports = Builder;

}).call(this);

//# sourceMappingURL=LtlsToLtls.js.map
