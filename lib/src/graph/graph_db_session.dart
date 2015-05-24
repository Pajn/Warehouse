part of warehouse.graph;

/// Holds state of the session like the queue of entities to create, update or delete.
///
/// For a server like HTTP or WebSocket the session should not be shared between requests
abstract class GraphDbSession implements DbSession, GraphRepository {

  /// Marks [entity] for deletion.
  ///
  /// If [deleteEdges] is not set the deletion will be rejected if [entity]
  /// is a node and still have edges to or from it. If it's set the edges will
  /// be deleted as well.
  @override
  void delete(entity, {bool deleteEdges: false});

  /// Delete every entity, optionally limited using a query.
  ///
  /// This action is performed directly and is not being queued.
  /// NOTE: The deleted entities will not be detached!
  ///
  /// [types] limits to entities only of only specified types, can be [List<Type>] or [Type]
  @override
  Future deleteAll({Map where, types});

  /// Only updates edges from a node (creates new, deletes old edges).
  ///
  /// No modifications are done on the node itself.
  void updateEdges(node);

  /// Get a single entity by [id].
  ///
  /// [types] limits to entities only of only specified types, can be [List<Type>] or [Type]
  /// [depth] specifies how relations should be resolved, see [findAll] for a description.
  @override
  Future get(id, {types, depth: 1});

  /// Get multiple entities by id.
  ///
  /// [types] limits to entities only of only specified types, can be [List<Type>] or [Type]
  /// [depth] specifies how relations should be resolved, see [findAll] for a description.
  @override
  Future<List> getAll(Iterable ids, {types, depth: 0});

  /// Find a single entity by a query.
  ///
  /// [types] limits to entities only of only specified types, can be [List<Type>] or [Type]
  /// [depth] specifies how relations should be resolved, see [findAll] for a description.
  @override
  Future find(Map where, {List<Type> types, depth: 1});

  /// Find all entities, optionally limited using queries.
  ///
  /// [types] limits to entities only of only specified types, can be [List<Type>] or [Type]
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [depth] specifies how relations should be resolved, valid values are:
  ///  - [int] A number that declares that all relations should be resolved to a maximum of that depth
  ///  - [String] The name of the relation that should be resolved
  ///  - [List] A list of all relations that should be resolved, can contain [String]s and [Map]s
  ///  - [Map] A map where keys are relations that should be resolved from this node and values that
  ///    are relations that should be resolved from that node. Keys can be [String]s and [List]s,
  ///    values can be [String]s, [List]s and [Map]s.
  @override
  Future<List> findAll({Map where, int skip: 0, int limit: 50, depth: 0, List<Type> types, String sort});

  /// Count all entities, optionally limited using queries.
  ///
  /// [types] limits to entities only of only specified types, can be [List<Type>] or [Type]
  /// [where] allows filtering on properties using [Matchers].
  @override
  Future<int> countAll({Map where, List<Type> types});
}
