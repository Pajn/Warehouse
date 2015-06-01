part of warehouse;

/// Holds state of the session like the queue of entities to create, update or delete.
///
/// For a server like HTTP or WebSocket the session should not be shared between requests
abstract class DbSession<T> {

  /// The database instance this session works against
  T get db;
  /// Registered companion database instances
  Map<Type, dynamic> get companions;
  /// If the database supports lists for properties (for example List<String>)
  bool get supportsListsAsProperty;

  /// Stream of operations in this session
  Stream<DbOperation> get onOperation;
  /// Stream of all entities created in this session
  Stream<DbOperation> get onCreated => onOperation.where((op) => op.type == OperationType.create);
  /// Stream of all entities deleted in this session
  Stream<DbOperation> get onDeleted => onOperation.where((op) => op.type == OperationType.delete);
  /// Stream of all entities updated in this session
  Stream<DbOperation> get onUpdated => onOperation.where((op) => op.type == OperationType.update);

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

  /// Registers a companion database
  Future registerCompanion(Type type, Companion companion);
}
