// Generated by CoffeeScript 1.10.0
(function() {
  var Neo4jRepostitory, assert, async, builder, should;

  should = require('should');

  assert = require('assert');

  async = require('async');

  Neo4jRepostitory = require('../src/repositories/Neo4jRepository');

  builder = require('../src/importers/edges/SweepsToWarehouses');

  describe('Build Edges', function() {
    return it('Wires Up Sweeps', function(done) {
      var repo, repoConfig;
      repoConfig = {
        user: 'neo4j',
        pass: 'macro7'
      };
      repo = new Neo4jRepostitory(repoConfig);
      builder.setRepo(repo);
      builder.buildSweepsToWarehouses(function(error, results) {
        if ((error != null)) {
          console.log(error);
          assert(false);
        }
        done();
      });
    });
  });

}).call(this);

//# sourceMappingURL=test_wireup_sweeps.js.map
