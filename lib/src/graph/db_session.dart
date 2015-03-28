part of warehouse.graph;

/// Holds state of the session like the queue of entities to create, update or delete.
abstract class GraphDbSession implements DbSession {
  Future get(id, {int maxDepth: 1, Type type});
  Future<List> getAll(Iterable ids, {int maxDepth: 0, Type type});

  Future find(Map where, {int maxDepth: 1, Type type}) =>
    findAll(where: where, limit: 1, maxDepth: maxDepth, type: type)
      .then((result) => result.isEmpty ? null : result.first);

  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [maxDepth] specifies how deep relations should be resolved
  Future<List> findAll({Map where, int skip: 0, int limit: 50, int maxDepth: 0, Type type});

  /// Fetches related nodes for [entity].
  Future resolveRelations(entity, {int depth: 1});
}
