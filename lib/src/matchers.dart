part of warehouse;

/// Matchers to specify in where queries.
///
/// Used though constants [IS] or [DO]
class Matcher {

  /// Only allows nodes which does have the field
  Matcher get exist => new ExistMatcher();

  /// Allows values which are not equal to [value].
  ///
  /// Optionally a matcher can be passed to negate its effect
  /// Example for allowing values that does not begin with the letter A
  /// `DO.not.match('A.*')`
  Matcher get not => new NotMatcher();

  const Matcher();

  /// Allows values which appear in the [list]
  Matcher inList(Iterable list) => new ListMatcher()..list = list;

  /// Allows values which are equal to [expected]
  Matcher equalTo(expected) => new EqualsMatcher()..expected = expected;
  /// Allows values which are less than [expected]
  Matcher lessThan(expected) => new LessThanMatcher()..expected = expected;
  /// Allows values which are less than or equal to [expected]
  Matcher lessThanOrEqualTo(expected) => new LessThanOrEqualToMatcher()..expected = expected;
  /// Allows values which are greater than [expected]
  Matcher greaterThan(expected) => new GreaterThanMatcher()..expected = expected;
  /// Allows values which are greater than or equal to [expected]
  Matcher greaterThanOrEqualTo(expected) => new GreaterThanOrEqualToMatcher()..expected = expected;
  /// Allow values which are in the range [min]..[max] inclusive.
  Matcher inRange(min, max) => new InRangeMatcher()..min = min..max = max;

  /// Allows values which matches the [regexp]
  Matcher match(String regexp) => new RegexpMatcher()..regexp = regexp;

  /// Allows values which are equal to [expected]
  operator ==(expected) => equalTo(expected);
  /// Allows values which are less than [expected]
  operator <(expected) => lessThan(expected);
  /// Allows values which are less than or equal to [expected]
  operator <=(expected) => lessThanOrEqualTo(expected);
  /// Allows values which are greater than [expected]
  operator >(expected) => greaterThan(expected);
  /// Allows values which are greater than or equal to [expected]
  operator >=(expected) => greaterThanOrEqualTo(expected);
}

class ExistMatcher extends Matcher {}
class NotMatcher<T extends Matcher> extends Matcher {
  T invertedMatcher;

  Matcher get exist => new NotMatcher<ExistMatcher>(super.exist);

  NotMatcher([this.invertedMatcher]);

  Matcher inList(Iterable list) => new NotMatcher<ListMatcher>(super.inList(list));
  Matcher equalTo(expected) => new NotMatcher<EqualsMatcher>(super.equalTo(expected));
  Matcher lessThan(num expected) => new NotMatcher<LessThanMatcher>(super.lessThan(expected));
  Matcher lessThanOrEqualTo(num expected) => new NotMatcher<LessThanOrEqualToMatcher>(super.lessThanOrEqualTo(expected));
  Matcher greaterThan(num expected) => new NotMatcher<GreaterThanMatcher>(super.greaterThan(expected));
  Matcher greaterThanOrEqualTo(num expected) => new NotMatcher<GreaterThanOrEqualToMatcher>(super.greaterThanOrEqualTo(expected));
  Matcher inRange(num min, num max) => new NotMatcher<InRangeMatcher>(super.inRange(min, max));
  Matcher match(String regexp) => new NotMatcher<RegexpMatcher>(super.match(regexp));
}
class ListMatcher extends Matcher { Iterable list; }
class EqualsMatcher extends Matcher { var expected; }
class LessThanMatcher extends Matcher { var expected; }
class LessThanOrEqualToMatcher extends Matcher { var expected; }
class GreaterThanMatcher extends Matcher { var expected; }
class GreaterThanOrEqualToMatcher extends Matcher { var expected; }
class InRangeMatcher extends Matcher { var min; var max; }
class RegexpMatcher extends Matcher { String regexp; }

const DO = const Matcher();
const IS = const Matcher();
