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
  Matcher lessThan(num expected) => new LessThanMatcher()..expected = expected;
  /// Allows values which are less than or equal to [expected]
  Matcher lessThanOrEqualTo(num expected) => new LessThanOrEqualToMatcher()..expected = expected;
  /// Allows values which are greater than [expected]
  Matcher greaterThan(num expected) => new GreaterThanMatcher()..expected = expected;
  /// Allows values which are greater than or equal to [expected]
  Matcher greaterThanOrEqualTo(num expected) => new GreaterThanOrEqualToMatcher()..expected = expected;
  /// Allow values which are in the range [min]..[max] inclusive.
  Matcher inRange(num min, num max) => new InRangeMatcher()..min = min..max = max;

  /// Allows values which matches the [regexp]
  Matcher match(String regexp) => new RegexpMatcher()..regexp = regexp;

  /// Allows values which are equal to [expected]
  operator ==(expected) => equalTo(expected);
  /// Allows values which are less than [expected]
  operator <(num expected) => lessThan(expected);
  /// Allows values which are less than or equal to [expected]
  operator <=(num expected) => lessThanOrEqualTo(expected);
  /// Allows values which are greater than [expected]
  operator >(num expected) => greaterThan(expected);
  /// Allows values which are greater than or equal to [expected]
  operator >=(num expected) => greaterThanOrEqualTo(expected);
}

class ExistMatcher extends Matcher {}
class NotMatcher extends Matcher {
  Matcher invertedMatcher;

  Matcher get exist => new NotMatcher(super.exist);

  NotMatcher([this.invertedMatcher]);

  Matcher inList(Iterable list) => new NotMatcher(super.inList(list));
  Matcher equalTo(expected) => new NotMatcher(super.equalTo(expected));
  Matcher lessThan(num expected) => new NotMatcher(super.lessThan(expected));
  Matcher lessThanOrEqualTo(num expected) => new NotMatcher(super.lessThanOrEqualTo(expected));
  Matcher greaterThan(num expected) => new NotMatcher(super.greaterThan(expected));
  Matcher greaterThanOrEqualTo(num expected) => new NotMatcher(super.greaterThanOrEqualTo(expected));
  Matcher inRange(num min, num max) => new NotMatcher(super.inRange(min, max));
  Matcher match(String regexp) => new NotMatcher(super.match(regexp));
}
class ListMatcher extends Matcher { Iterable list; }
class EqualsMatcher extends Matcher { var expected; }
class LessThanMatcher extends Matcher { num expected; }
class LessThanOrEqualToMatcher extends Matcher { num expected; }
class GreaterThanMatcher extends Matcher { num expected; }
class GreaterThanOrEqualToMatcher extends Matcher { num expected; }
class InRangeMatcher extends Matcher { num min; num max; }
class RegexpMatcher extends Matcher { String regexp; }

const DO = const Matcher();
const IS = const Matcher();
