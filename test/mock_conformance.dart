library warehouse.test.mock_conformance;

import 'package:warehouse/adapters/conformance_tests.dart';
import 'package:warehouse/mocks.dart';

main() {
  runConformanceTests(
      () => new MockSession(),
      (session, type) => new MockRepository.withTypes(session, [type])
  );
}
