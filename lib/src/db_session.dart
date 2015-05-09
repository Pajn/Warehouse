part of warehouse;

/// Holds state of the session like the queue of entities to create, update or delete.
///
/// For a server like HTTP or WebSocket the session should not be shared between requests
abstract class DbSession<T> {

  /// The database instance this session works against
  T get db;
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

  /// Detaches an entity from the session.
  ///
  /// By detaching an entity the session will not know about the object and will call create instead
  /// of update on store and will not allow deleting. This should normally not be needed to be
  /// called manually but can be called in case an object is deleted in other ways than through the
  /// session or a [Repository] attached to a session.
  void detach(entity);

  /// Clears the currently queued tasks
  void clearQueue();

  /// Disposes the session so that it's no longer usable.
  ///
  /// Disposing a session is useful for stopping the [onOperation]  stream so that listeners exit
  /// gracefully.
  void dispose();

  /// Marks [entity] for deletion.
  void delete(entity);

  /// Marks [entity] for creation or update.
  void store(entity);

  /// Persist the queue of changes to the database
  Future saveChanges();

  /// Delete every entity, optionally limited using a query.
  ///
  /// This action is performed directly and is not being queued.
  /// NOTE: The deleted entities will not be detached!
  ///
  /// [type] limits to entities only of that [Type]
  Future deleteAll({Map where, Type type});

  /// Get a single entity by [id].
  ///
  /// [type] limits to entities only of that [Type]
  Future get(id, {Type type});

  /// Get multiple entities by id.
  ///
  /// [type] limits to entities only of that [Type]
  Future<List> getAll(Iterable ids, {Type type}); // Stream?

  /// Find a single entity by a query.
  ///
  /// [type] limits to entities only of that [Type]
  Future find(Map where, {Type type});

  /// Find all entities, optionally limited using queries.
  ///
  /// [type] limits to entities only of that [Type]
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [sort] specifies a field that the result should be sorted on
  Future<List> findAll({Map where, int skip: 0, int limit: 50, Type type, String sort}); // Stream?

  /// Count all entities, optionally limited using queries.
  ///
  /// [type] limits to entities only of that [Type]
  /// [where] allows filtering on properties using [Matchers].
  Future<int> countAll({Map where, Type type});

  /// Registers a companion database
  void registerCompanion(Type type, Companion companion);
}
