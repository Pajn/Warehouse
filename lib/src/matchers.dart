part of warehouse;

abstract class Matcher {
  const Matcher();
}

/// Matchers to specify in where queries.
///
/// Used though constants [IS] or [DO]
class NormalMatcher extends Matcher {

  /// Only allows nodes which does have the field
  Matcher get exist => new ExistMatcher();

  /// Allows values which are not equal to [value].
  ///
  /// Optionally a matcher can be passed to negate its effect
  /// Example for allowing values that does not begin with the letter A
  /// `DO.not.match('A.*')`
  NotMatcher get not => new NotMatcher();

  const NormalMatcher();

  /// Allows values which appear in the [list]
  Matcher inList(Iterable list) => new ListMatcher()..list = list;

  /// Allows values which [expected] are a part of
  Matcher contain(expected) => new ContainMatcher()..expected = expected;

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
class NotMatcher<T extends Matcher> extends NormalMatcher implements Function {
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
class ListMatcher extends Matcher { Iterable list; }
class ContainMatcher extends Matcher { var expected; }
class EqualsMatcher extends Matcher { var expected; }
class LessThanMatcher extends Matcher { var expected; }
class LessThanOrEqualToMatcher extends Matcher { var expected; }
class GreaterThanMatcher extends Matcher { var expected; }
class GreaterThanOrEqualToMatcher extends Matcher { var expected; }
class InRangeMatcher extends Matcher { var min; var max; }
class RegexpMatcher extends Matcher { String regexp; }

const DO = const NormalMatcher();
const IS = const NormalMatcher();
//
//get IS => new Matcher();
//get DO => new Matcher();
//
//part of warehouse;
//
///// Matchers to specify in where queries.
/////
///// Used though constants [IS] or [DO]
//class Matcher<T extends Matcher> {
//  var matcher;
//
//  /// Only allows nodes which does have the field
//  T get exist {
//    matcher = new ExistMatcher();
//    return this;
//  }
//
//  /// Allows values which are not equal to [value].
//  ///
//  /// Optionally a matcher can be passed to negate its effect
//  /// Example for allowing values that does not begin with the letter A
//  /// `DO.not.match('A.*')`
//  T get not {
//    matcher = new NotMatcher();
//    return this;
//  }
//
//  /// Allows values which appear in the [list]
//  T inList(Iterable list) {
//    matcher = new ListMatcher()..list = list;
//    return this;
//  }
//
//  /// Allows values which are equal to [expected]
//  T equalTo(expected) {
//    matcher =  new EqualsMatcher()..expected = expected;
//    return this;
//  }
//  /// Allows values which are less than [expected]
//  T lessThan(expected) {
//    matcher =  new LessThanMatcher()..expected = expected;
//    return this;
//  }
//  /// Allows values which are less than or equal to [expected]
//  T lessThanOrEqualTo(expected) {
//    matcher =  new LessThanOrEqualToMatcher()..expected = expected;
//    return this;
//  }
//  /// Allows values which are greater than [expected]
//  T greaterThan(expected) {
//    matcher =  new GreaterThanMatcher()..expected = expected;
//    return this;
//  }
//  /// Allows values which are greater than or equal to [expected]
//  T greaterThanOrEqualTo(expected) {
//    matcher =  new GreaterThanOrEqualToMatcher()..expected = expected;
//    return this;
//  }
//  /// Allow values which are in the range [min]..[max] inclusive.
//  T inRange(min, max) {
//    matcher =  new InRangeMatcher()..min = min..max = max;
//    return this;
//  }
//
//  /// Allows values which matches the [regexp]
//  T match(String regexp) {
//    matcher =  new RegexpMatcher()..regexp = regexp;
//    return this;
//  }
//
//  /// Allows values which are equal to [expected]
//  operator ==(expected) => equalTo(expected);
//  /// Allows values which are less than [expected]
//  operator <(expected) => lessThan(expected);
//  /// Allows values which are less than or equal to [expected]
//  operator <=(expected) => lessThanOrEqualTo(expected);
//  /// Allows values which are greater than [expected]
//  operator >(expected) => greaterThan(expected);
//  /// Allows values which are greater than or equal to [expected]
//  operator >=(expected) => greaterThanOrEqualTo(expected);
//}
//
//class ExistMatcher extends Matcher {}
//class NotMatcher<T extends Matcher> extends Matcher {
//  T invertedMatcher;
//
//  Matcher get exist => new NotMatcher<ExistMatcher>(super.exist);
//
//  NotMatcher([this.invertedMatcher]);
//
//  Matcher inList(Iterable list) => new NotMatcher<ListMatcher>(super.inList(list));
//  Matcher equalTo(expected) => new NotMatcher<EqualsMatcher>(super.equalTo(expected));
//  Matcher lessThan(num expected) => new NotMatcher<LessThanMatcher>(super.lessThan(expected));
//  Matcher lessThanOrEqualTo(num expected) => new NotMatcher<LessThanOrEqualToMatcher>(super.lessThanOrEqualTo(expected));
//  Matcher greaterThan(num expected) => new NotMatcher<GreaterThanMatcher>(super.greaterThan(expected));
//  Matcher greaterThanOrEqualTo(num expected) => new NotMatcher<GreaterThanOrEqualToMatcher>(super.greaterThanOrEqualTo(expected));
//  Matcher inRange(num min, num max) => new NotMatcher<InRangeMatcher>(super.inRange(min, max));
//  Matcher match(String regexp) => new NotMatcher<RegexpMatcher>(super.match(regexp));
//}
//class ListMatcher extends Matcher { Iterable list; }
//class EqualsMatcher extends Matcher { var expected; }
//class LessThanMatcher extends Matcher { var expected; }
//class LessThanOrEqualToMatcher extends Matcher { var expected; }
//class GreaterThanMatcher extends Matcher { var expected; }
//class GreaterThanOrEqualToMatcher extends Matcher { var expected; }
//class InRangeMatcher extends Matcher { var min; var max; }
//class RegexpMatcher extends Matcher { String regexp; }
//
////const DO = const Matcher();
////const IS = const Matcher();
//
//get IS => new Matcher();
//get DO => new Matcher();
