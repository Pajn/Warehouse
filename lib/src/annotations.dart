part of warehouse;

/// Mark the filed to show that the relation is incoming from another entity.
///
/// Example:
///     class Person {
///       @ReverseOf(#employees)
///       Company worksAt
///     }
///
///     class Company {
///       List<Person> employees;
///     }
class ReverseOf {
  /// The name of the [field] in the class that the relation starts from
  final Symbol field;

  const ReverseOf(this.field);
}

/// Makes Warehouse ignore the field and not store it in the database
class Ignore {
  const Ignore();
}
