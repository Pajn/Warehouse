import 'package:unittest/unittest.dart';

import 'specs/mirrors/looking_glass.dart' as looking_glass;
import 'mock_conformance.dart' as mock_conformance;

class TestConfiguration extends SimpleConfiguration {
  onTestResult(TestCase result) {
    print(formatResult(result).trim());
  }

  void onSummary(int passed, int failed, int errors, List<TestCase> results,
                 String uncaughtError) {
    // Show the summary.
    print('');

    if (passed == 0 && failed == 0 && errors == 0 && uncaughtError == null) {
      print('No tests found.');
      // This is considered a failure too.
    } else if (failed == 0 && errors == 0 && uncaughtError == null) {
      print('All $passed tests passed.');
    } else {
      if (uncaughtError != null) {
        print('Top-level uncaught error: $uncaughtError');
      }
      print('$passed PASSED, $failed FAILED, $errors ERRORS');
    }
  }
}

main() {
  unittestConfiguration = new TestConfiguration();
  looking_glass.main();
  mock_conformance.main();
}
