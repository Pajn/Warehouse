part of warehouse.graph;

/// Mark the entity as an edge rather than a node or vertex
///
/// Example:
///     class Person {
///       @ReverseOf(#employees)
///       Employment worksAt
///     }
///
///     @Edge(Company, Person)
///     class Employment {
///       int salary;
///
///       // Optionally add references back to the nodes, depending on how you query the data
///       // this may be needed to reach the other node. For example
///       // personRepository.get(1).worksAt.company;
///       Company company;
///       Person person;
///     }
///
///     class Company {
///       List<Employment> employees;
///     }
class Edge {
  /// The class the relation starts from
  final Type start;
  /// The class the relation ends in
  final Type end;

  const Edge(this.start, this.end);
}
