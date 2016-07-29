// Generated by CoffeeScript 1.10.0
(function() {
  var assert, driver, math, neo4j, should;

  should = require('should');

  assert = require('assert');

  math = require('mathjs');

  neo4j = require('neo4j-driver').v1;

  driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j', 'macro7'));

  describe('Test Routes', function() {
    var buildGraph, deleteGraph;
    deleteGraph = function(done) {
      var session, tx;
      session = driver.session();
      tx = session.beginTransaction();
      console.log("Delete edges");
      tx.run("MATCH ()-[r]->() DELETE r");
      console.log("Delete nodes");
      tx.run("MATCH (n) delete n");
      return tx.commit().subscribe({
        onCompleted: function() {
          console.log("delete completed");
          session.close();
          return done();
        },
        onError: function(error) {
          console.log(error);
          session.close();
          return done();
        }
      });
    };
    buildGraph = function(done) {
      var props, session, tx, upsert;
      props = {
        value: "1",
        prop1: "a",
        prop2: "c"
      };
      upsert = "MERGE (n:Test { id: {value}, prop1:{a} prop2:{b} }) ON CREATE SET n.created=timestamp()";
      session = driver.session();
      tx = session.beginTransaction();
      tx.run(upsert, props);
      return tx.commit().subscribe({
        onCompleted: function() {
          var session2, tx2;
          session.close();
          session2 = driver.session2();
          tx2 = session2.beginTransaction();
          tx2.run(upsert, props);
          return tx.commit().subscribe({
            onCompleted: function() {
              return done();
            }
          });
        }
      });
    };
    return before(function(done) {
      return deleteGraph(function() {
        return buildGraph(done);
      });
    });
  });

}).call(this);

//# sourceMappingURL=test_routes.js.map
