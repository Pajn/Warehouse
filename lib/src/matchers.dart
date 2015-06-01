part of warehouse;

abstract class Matcher {
  const Matcher();
}

/// Matchers to specify in where queries.
///
/// Used though constants [IS] or [DO]
class NormalMatchers extends Matcher {

  /// Only allows nodes which does have the field
  Matcher get exist => new ExistMatcher();

  /// Allows values which are not equal to [value].
  ///
  /// Optionally a matcher can be passed to negate its effect
  /// Example for allowing values that does not begin with the letter A
  /// `DO.not.match('A.*')`
  NotMatcher get not => new NotMatcher();

  const NormalMatchers();

  /// Allows values which appear in the [list]
  Matcher inList(Iterable list) => new InListMatcher()..list = list;

  /// Allows strings which contain [expected]
  Matcher contain(String expected) => new StringContainMatcher()..expected = expected;

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
class NotMatcher<T extends Matcher> extends NormalMatchers implements Function {
  T invertedMatcher;

  Matcher get exist => new NotMatcher<ExistMatcher>(super.exist);

  NotMatcher([this.invertedMatcher]);

  Matcher inList(Iterable list) => new NotMatcher(super.inList(list));
  Matcher equalTo(expected) => new NotMatcher(super.equalTo(expected));
  Matcher lessThan(expected) => new NotMatcher(super.lessThan(expected));
  Matcher lessThanOrEqualTo(expected) => new NotMatcher(super.lessThanOrEqualTo(expected));
  Matcher greaterThan(expected) => new NotMatcher(super.greaterThan(expected));
  Matcher greaterThanOrEqualTo(expected) => new NotMatcher(super.greaterThanOrEqualTo(expected));
  Matcher inRange(min, max) => new NotMatcher(super.inRange(min, max));
  Matcher match(String regexp) => new NotMatcher(super.match(regexp));

  call(Matcher toInvert) {
    invertedMatcher = toInvert;
    return this;
  }
}
class InListMatcher extends Matcher { Iterable list; }
class StringContainMatcher extends Matcher { String expected; }
class EqualsMatcher extends Matcher { var expected; }
class LessThanMatcher extends Matcher { var expected; }
class LessThanOrEqualToMatcher extends Matcher { var expected; }
class GreaterThanMatcher extends Matcher { var expected; }
class GreaterThanOrEqualToMatcher extends Matcher { var expected; }
class InRangeMatcher extends Matcher { var min; var max; }
class RegexpMatcher extends Matcher { String regexp; }

/// List matchers to specify in where queries.
///
/// Used though constant [list]
class ListMatchers extends Matcher {
  const ListMatchers();

  /// Allows lists which contains [expected]
  Matcher contains(expected) => new ListContainsMatcher()..expected = expected;
}

class ListContainsMatcher extends Matcher { var expected; }

const DO = const NormalMatchers();
const IS = const NormalMatchers();
const list = const ListMatchers();
