/// A conformance test suite to run adapters against
///
/// Tests intended to verify than an adapter works as intended and is interchangeable
/// with other adapters of the same database model.
/// They also serves as examples on using Warehouse
library warehouse.adapter.conformance_tests;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show unittestConfiguration;
import 'package:warehouse/graph.dart';

import 'package:warehouse/src/adapters/conformance_tests/domain.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';

import 'package:warehouse/src/adapters/conformance_tests/specs/session.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/store.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/delete.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/get.dart';
import 'package:warehouse/src/adapters/conformance_tests/specs/find.dart';

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
runGraphTests(GraphSessionFactory sessionFactory) {
  describe('Graph', () {

  });
}

/// Runs all tests applicable for the passed [session]
runConformanceTests(SessionFactory sessionFactory, RepositoryFactory repositoryFactory) {
  unittestConfiguration.timeout = const Duration(seconds: 3);

  describe('Warehouse conformance', () {
    beforeEach(() async {
      var session = sessionFactory();
      await repositoryFactory(session, Movie).deleteAll();
      await repositoryFactory(session, Person).deleteAll();
    });

    runGenericTests(sessionFactory, repositoryFactory);

    if (sessionFactory() is GraphDbSession) runGraphTests(sessionFactory);
  });
}
