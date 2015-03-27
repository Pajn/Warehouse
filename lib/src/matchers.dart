/**
 * Matchers to specify in where queries.
 *
 * Used though constants [IS] or [DO]
 */
abstract class Matchers implements Function {

  /// Only allows nodes which does have the field
  Matchers get exist;

  /**
   * Allows values which are not equal to [value].
   *
   * Optionally a matcher can be passed to negate its effect
   * Example for allowing values that does not begin with the letter A
   * `DO.not.match('A.*')`
   */
  Matchers get not;

  const Matchers();

  /// Allows values which appear in the [list]
  Matchers inList(Iterable list);
  /// Allows values which do not appear in the [list]
  Matchers notInList(Iterable list);

  /// Allows values which are equal to [expected]
  Matchers equalTo(expected);
  /// Allows values which are less than [expected]
  Matchers lessThan(num expected);
  /// Allows values which are less than or equal to [expected]
  Matchers lessThanOrEqualTo(num expected);
  /// Allows values which are greater than [expected]
  Matchers greaterThan(num expected);
  /// Allows values which are greater than or equal to [expected]
  Matchers greaterThanOrEqualTo(num expected);

  /// Allows values which matches the [regexp]
  Matchers match(String regexp);

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
