part of warehouse.graph;

/// A repository for graph backends
class GraphRepository<T> extends Repository<T> {

  final GraphDbSession session;

  GraphRepository(GraphDbSession session) : this.session = session, super(session);

  Future<T> get(id, {int maxDepth: 1}) => session.get(id, maxDepth: maxDepth, type: T);
  Future<List<T>> getAll(Iterable ids, {int maxDepth: 0}) =>
    session.getAll(ids, maxDepth: maxDepth, type: T);

  Future<T> find(Map where, {int maxDepth: 1}) => session.find(where, maxDepth: maxDepth, type: T);

  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [maxDepth] specifies how deep relations should be resolved
  Future<List<T>> findAll({Map where, int skip: 0, int limit: 50, int maxDepth: 0}) =>
    session.findAll(where: where, skip: skip, limit: limit, maxDepth: maxDepth, type: T);

  /// Fetches related nodes for [entity].
  Future<T> resolveRelations(T entity, {int depth: 1}) =>
    session.resolveRelations(entity, depth: depth);
}
