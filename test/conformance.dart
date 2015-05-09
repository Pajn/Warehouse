/// A conformance test suite to run adapters against
///
/// Tests intended to verify than an adapter works as intended and is interchangeable
/// with other adapters of the same database model.
/// They also serves as examples on using Warehouse
library warehouse.test.conformance;

import 'package:guinness/guinness.dart';
import 'package:warehouse/graph.dart';
import 'package:warehouse/warehouse.dart';

import 'conformance/specs/session.dart';
import 'conformance/specs/store.dart';
import 'conformance/specs/delete.dart';
import 'conformance/specs/get.dart';
import 'conformance/specs/find.dart';

/// Runs tests that should work with any database model.
runGenericTests(DbSession session) {
  describe('Generic', () {
    runSessionTests(session);
    runStoreTests(session);
    runDeleteTests(session);
    runGetTests(session);
    runFindTests(session);
  });
}

/// Runs tests that should work with any graph database.
runGraphTests(GraphDbSession session) {
  describe('Graph', () {

  });
}

/// Runs all tests applicable for the passed [session]
runTests(DbSession session) {
  describe('Warehouse conformance', () {
    runGenericTests(session);

    if (session is GraphDbSession) runGraphTests(session);
  });
}
