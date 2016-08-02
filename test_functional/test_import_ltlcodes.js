// Generated by CoffeeScript 1.10.0
(function() {
  var Neo4jRepostitory, Papa, assert, async, fs, importer, should;

  should = require('should');

  assert = require('assert');

  importer = require('../src/importers/importLtlCodes');

  async = require('async');

  Neo4jRepostitory = require('../src/repositories/Neo4jRepository');

  fs = require('fs');

  Papa = require('babyparse');

  describe('Import LtlCodes', function() {
    var checkAllNodes;
    checkAllNodes = (function(_this) {
      return function(filename, repo, done) {
        var contents, data, getFuncs, i, id, j, len, make, node, result, v;
        contents = fs.readFileSync(filename, 'utf8');
        result = Papa.parse(contents, _this.config);
        data = result.data;
        make = function(id, type) {
          return function(callback) {
            return repo.get({
              id: id,
              type: type
            }, function(error, result) {
              JSON.parse(result).id.should.be.equal(id);
              callback(null, result);
            });
          };
        };
        getFuncs = [];
        for (i = j = 0, len = data.length; j < len; i = ++j) {
          node = data[i];
          if (i === 0) {
            continue;
          }
          id = ((function() {
            var k, len1, results1;
            results1 = [];
            for (k = 0, len1 = node.length; k < len1; k++) {
              v = node[k];
              results1.push(v);
            }
            return results1;
          })()).reduce(function(x, y) {
            return "" + x + "_" + y;
          });
          if (id !== "") {
            getFuncs.push(make(id, 'LtlCode'));
          }
        }
        async.parallelLimit(getFuncs, 1, function(error, results) {
          if (error != null) {
            console.log('error' + error);
            assert(false);
          }
          done();
        });
      };
    })(this);
    return it('Imports LtlCodes Neo4j', function(done) {
      var filename, repo, repoConfig;
      repoConfig = {
        user: 'neo4j',
        pass: 'macro7'
      };
      repo = new Neo4jRepostitory(repoConfig);
      filename = './data/weights-codes.csv';
      return importer.importKeyValue(filename, repo, function(error, results) {
        if ((error != null)) {
          console.log(error);
          assert(false);
          done();
          return;
        }
        repo.get({
          id: '15000_1500_2500',
          type: 'LtlCode'
        }, function(error, result) {
          var data;
          if ((error != null)) {
            assert(false);
            done();
            return;
          }
          data = JSON.parse(result);
          data.ltlCode.should.be.equal('15000');
          data.weightLo.should.be.equal('1500');
          data.weightHi.should.be.equal('2500');
          checkAllNodes(filename, repo, done);
        });
      });
    });
  });

}).call(this);

//# sourceMappingURL=test_import_ltlcodes.js.map
