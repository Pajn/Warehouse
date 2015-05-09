part of warehouse.graph;

/// Holds state of the session like the queue of entities to create, update or delete.
///
/// For a server like HTTP or WebSocket the session should not be shared between requests
abstract class GraphDbSession implements DbSession {
  /// Get a single entity by [id].
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future get(id, {Type type, depth: 1});

  /// Get multiple entities by id.
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<List> getAll(Iterable ids, {Type type, depth: 0});

  /// Find a single entity by a query.
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future find(Map where, {Type type, depth: 1}) =>
    findAll(where: where, limit: 1, type: type, depth: depth)
      .then((result) => result.isEmpty ? null : result.first);

  /// Find all entities, optionally limited using queries.
  ///
  /// [type] limits to entities only of that [Type]
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<List> findAll({Map where, int skip: 0, int limit: 50, depth: 0, Type type, String sort});

  /// Fetches related nodes for [entity].
  ///
  /// [depth] specifies how relations should be resolved, valid values are:
  ///  - [int] A number that declares that all relations should be resolved to a maximum of that depth
  ///  - [String] The name of the relation that should be resolved
  ///  - [List] A list of all relations that should be resolved, can contain [String]s and [Map]s
  ///  - [Map] A map where keys are relations that should be resolved from this node and values that
  ///    are relations that should be resolved from that node. Keys can be [String]s and [List]s,
  ///    values can be [String]s, [List]s and [Map]s.
  Future resolveRelations(entity, {int depth: 1});
}
