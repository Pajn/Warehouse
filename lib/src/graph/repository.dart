part of warehouse.graph;

/// A generic repository for working with a [GraphDbSession]
///
/// The repository needs a type of the objects it will work with. It can either be specified while
/// instantiating an object with `var movieRepository = new Repository<Movie>();` or by inheriting
/// the [Repository] class with `class MovieRepository extends Repository<Movie> {}`.
class GraphRepository<T> extends Repository<T> {
  final GraphDbSession session;

  GraphRepository(GraphDbSession session) : super(session);

  /// Get a single entity by [id].
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<T> get(id, {depth: 1}) => session.get(id, depth: depth, type: T);

  /// Get multiple entities by id.
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<List<T>> getAll(Iterable ids, {depth: 0}) =>
    session.getAll(ids, depth: depth, type: T);

  /// Find a single entity by a query.
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<T> find(Map where, {depth: 1}) => session.find(where, depth: depth, type: T);

  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<List<T>> findAll({Map where, int skip: 0, int limit: 50, depth: 0}) =>
    session.findAll(where: where, skip: skip, limit: limit, depth: depth, type: T);


  /// Fetches related nodes for [entity].
  ///
  /// [depth] specifies how relations should be resolved, valid values are:
  ///  - [int] A number that declares that all relations should be resolved to a maximum of that depth
  ///  - [String] The name of the relation that should be resolved
  ///  - [List] A list of all relations that should be resolved, can contain [String]s and [Map]s
  ///  - [Map] A map where keys are relations that should be resolved from this node and values that
  ///    are relations that should be resolved from that node. Keys can be [String]s and [List]s,
  ///    values can be [String]s, [List]s and [Map]s.
  Future<T> resolveRelations(T entity, {depth: 1}) =>
    session.resolveRelations(entity, depth: depth);
}
