part of warehouse.graph;

/// Mark the filed to show that the relation is incoming from another node.
///
/// Example:
///     class Person {
///       @ReverseOf(#employees)
///       Company worksAt
///     }
///
///     class Company {
///        List<Person> employees;
///     }
class ReverseOf {
  /// The name of the [field] in the class that the relation starts from
  final Symbol field;

  const ReverseOf(this.field);
}

/// Mark the entity as a relation or edge rather than a node or vertex
class Relation {
  /// The class the relation starts from
  final Type start;
  /// The class the relation ends in
  final Type end;

  const Relation(this.start, this.end);
}
