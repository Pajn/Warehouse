import 'dart:async';

typedef Companion(DbSession session);

/// Holds state of the session like the queue of entities to create, update or delete.
abstract class DbSession {
  /// Stream of operations in this session
  Stream<DbOperation> get onOperation;
  /// Stream of all entities created in this session
  Stream<DbOperation> get onCreated => onOperation.where((op) => op.operation == OperationType.create);
  /// Stream of all entities deleted in this session
  Stream<DbOperation> get onDeleted => onOperation.where((op) => op.operation == OperationType.delete);
  /// Stream of all entities updated in this session
  Stream<DbOperation> get onUpdated => onOperation.where((op) => op.operation == OperationType.update);

  /// Get the database id of [entity]
  dynamic entityId(entity);

  /// Marks [entity] for deletion.
  void delete(entity);
  /// Marks [entity] for creation or update.
  void store(entity);
  /// Persist the queue of changes to the database
  Future saveChanges();

  void addCompanion(Companion companion) => companion(this);
}

abstract class Repository<T> {
  final DbSession session;

  /// Stream of entities created in this session of type [T]
  Stream<DbOperation<T>> get onCreated => session.onCreated.where((op) => op.entity is T);
  /// Stream of entities deleted in this session of type [T]
  Stream<DbOperation<T>> get onDeleted => session.onDeleted.where((op) => op.entity is T);
  /// Stream of entities updated in this session of type [T]
  Stream<DbOperation<T>> get onUpdated => session.onUpdated.where((op) => op.entity is T);

  Repository(this.session);

  /// Get a single entity by [id].
  Future<T> get(id);
  /// Get multiple entities by id.
  Future<List<T>> getAll(List ids); // Stream?

  /// Find a single entity by a query.
  Future<T> find(where);
  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  Future<List<T>> findAll({Map where, int skip, int limit}); // Stream?
  /// Count all entities of type [T], optionally limited using a query.
  Future<int> countAll({Map where});
}

/// Mixin to a [Repository] to add searching for entities using a companion database.
abstract class Search<T> {
  // How should [query] look and behave? May be to hard and limited to abstract by may not be very
  // useful otherwise?
  Future<List<T>> search(query);
}

enum OperationType {
  create, delete, update
}

class DbOperation<T> {
  var id;
  OperationType operation;
  T entity;
}
