/// A conformance test suite to run adapters against
///
/// Tests intended to verify than an adapter works as intended and is interchangeable
/// with other adapters of the same database model.
/// They also serves as examples on using Warehouse
library warehouse.adapter.conformance_tests;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show unittestConfiguration;
import 'package:warehouse/graph.dart';
import 'package:warehouse/sql.dart';

import 'package:warehouse/src/adapters/conformance_tests/domain.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';

import 'package:warehouse/src/adapters/conformance_tests/specs/session.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/store.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/delete.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/get.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/find.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/graph/delete.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/graph/depth.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/graph/edge.dart';

Future registerModels(SqlDb db) async {
  db.registerModel(Movie, subtypes: const [AnimatedMovie]);
  db.registerModel(Person);
  db.registerModel(DefaultValue);
  db.registerModel(Base, subtypes: const [Child]);
  db.registerModel(PrivateValue);
  db.registerModel(OnlyGetter);
  await db.createTables();
}

/// Runs tests that should work with any database model.
runGenericTests(SessionFactory sessionFactory, RepositoryFactory repositoryFactory) {
  describe('Generic', () {
    runSessionTests(sessionFactory);
    runStoreTests(sessionFactory, repositoryFactory);
    runDeleteTests(sessionFactory, repositoryFactory);
    runGetTests(sessionFactory, repositoryFactory);
    runFindTests(sessionFactory, repositoryFactory);
  });
}

/// Runs tests that should work with any graph database.
runGraphTests(GraphSessionFactory sessionFactory, RepositoryFactory repositoryFactory) {
  describe('Graph', () {
    beforeEach(() async {
      await sessionFactory().deleteAll();
    });

    // If the default GraphRepository is used by the adapter then we know that
    // the sessions read support have already been tested.
    if (repositoryFactory(sessionFactory(), null).runtimeType != GraphRepository) {
      describe('session as repository', () {
        runGetTests(sessionFactory, repositoryFactory);
        runFindTests(sessionFactory, repositoryFactory);
      });
    }

    runDepthTests(sessionFactory);
    runEdgeTests(sessionFactory);
    runGraphDeleteTests(sessionFactory);
  });
}

/// Runs all tests applicable for the passed [session]
runConformanceTests(SessionFactory sessionFactory, RepositoryFactory repositoryFactory, {
    Duration testTimeout: const Duration(seconds: 3)
  }) {
  unittestConfiguration.timeout = testTimeout;

  describe('Warehouse conformance', () {
    beforeEach(() async {
      var session = sessionFactory();
      await repositoryFactory(session, Movie).deleteAll();
      await repositoryFactory(session, Person).deleteAll();
    });

    runGenericTests(sessionFactory, repositoryFactory);

    if (sessionFactory() is GraphDbSession) runGraphTests(sessionFactory, repositoryFactory);
  });
}
