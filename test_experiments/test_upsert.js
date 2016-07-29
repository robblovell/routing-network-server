// Generated by CoffeeScript 1.10.0
(function() {
  var assert, driver, math, neo4j, should, uuid;

  should = require('should');

  assert = require('assert');

  math = require('mathjs');

  uuid = require('uuid');

  neo4j = require('neo4j-driver').v1;

  driver = neo4j.driver('bolt://localhost', neo4j.auth.basic('neo4j', 'macro7'));

  describe('Test Routes', function() {
    var buildGraph, deleteGraph, makeIdNode, makeUpsert;
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
    makeUpsert = function(node, data) {
      var create, key, properties, update, upsertStatement, value;
      if (!(data.id != null)) {
        data.id = uuid.v4();
      }
      properties = ((function() {
        var results;
        results = [];
        for (key in data) {
          value = data[key];
          results.push("n." + key + " = {" + key + "}, ");
        }
        return results;
      })()).reduce(function(t, s) {
        return t + s;
      });
      properties = properties.slice(0, -2);
      create = "n.created=timestamp(), " + properties;
      update = "n.updated=timestamp(), " + properties;
      upsertStatement = ("MERGE (n:" + node + " { id: neo4j.int({id}) }) ON CREATE SET ") + create + " ON MATCH SET " + update;
      return upsertStatement;
    };
    makeIdNode = function() {
      var makeStatement;
      makeStatement = makeUpsert({
        id: id
      });
      return makeStatement;
    };
    buildGraph = function(done) {
      var props, session, tx, upsert;
      tx = session.beginTransaction();
      tx.run(upsert, props);
      tx.commit().subscribe({
        onCompleted: function(result) {}
      });
      props = {
        prop1: "x",
        prop2: "z"
      };
      upsert = makeUpsert('Test', props);
      console.log("12345678901234567890123456789012345678901234567890123456789012345678901234567890");
      console.log(upsert);
      session = driver.session();
      tx = session.beginTransaction();
      tx.run(upsert, props);
      return tx.commit().subscribe({
        onCompleted: function(result) {
          var session2, tx2;
          session.close();
          session2 = driver.session();
          tx2 = session2.beginTransaction();
          props = {
            id: 449,
            prop1: "231",
            prop2: "1000"
          };
          tx2.run(upsert, props);
          return tx2.commit().subscribe({
            onCompleted: function() {
              session2.close();
              return done();
            },
            onError: function(error) {
              console.log(error);
              session2.close();
              return done();
            }
          });
        },
        onError: function(error) {
          console.log(error);
          session.close();
          return done();
        }
      });
    };
    return it('upserts', function(done) {
      return deleteGraph(function() {
        return buildGraph(done);
      });
    });
  });

}).call(this);

//# sourceMappingURL=test_upsert.js.map