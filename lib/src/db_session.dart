part of warehouse;

/// Holds state of the session like the queue of entities to create, update or delete.
abstract class DbSession {

  /// The database instance this session works against
  dynamic get db;
  /// Registered companion database instances
  Map<Type, dynamic> get companions;

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

  /// Attaches an entity to the session.
  ///
  /// By attaching an entity the session knows about the object and will call update instead of
  /// create on store and allow deleting. This should normally not be needed to be called manually
  /// but can be called in case an object is created in other ways than through the session or a
  /// [Repository] attached to a session.
  void attach(entity, id);

  /// Marks [entity] for deletion.
  void delete(entity);

  /// Marks [entity] for creation or update.
  void store(entity);

  /// Persist the queue of changes to the database
  Future saveChanges();

  /// Get a single entity by [id].
  Future get(id, {Type type});

  /// Get multiple entities by id.
  Future<List> getAll(List ids, {Type type}); // Stream?

  /// Find a single entity by a query.
  Future find(Map where, {Type type});

  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  Future<List> findAll({Map where, int skip: 0, int limit: 50, Type type}); // Stream?

  /// Count all entities of type [T], optionally limited using a query.
  Future<int> countAll({Map where, Type type});

  /// Registers a companion database
  void registerCompanion(Type type, Companion companion);
}
