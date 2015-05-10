part of warehouse.adapter;

/// Class to be inherited when developing an adapter
abstract class DbSessionBase<T> extends DbSession<T> {

  /// All entities known by the session
  final Expando entities = new Expando();

  /// Queue to be persisted when [saveChanges] is called
  final List<DbOperation> queue = [];

  /// Controls the [onOperation] stream, all persisted operations in the [queue] is added here.
  final StreamController<DbOperation> operations = new StreamController.broadcast();

  bool _disposed = false;

  @override
  final Map<Type, dynamic> companions = new HashMap();

  @override
  Stream<DbOperation> get onOperation => operations.stream;

  @override
  entityId(entity) => entities[entity];

  @override
  void attach(entity, id) => entities[entity] = id;

  @override
  void detach(entity) => entities[entity] = null;

  @override
  void dispose() {
    clearQueue();
    operations.close();
    _disposed = true;
  }

  @override
  void clearQueue() => queue.clear();

  @override
  Future find(Map where, {Type type}) =>
    findAll(where: where, limit: 1, type: type)
      .then((result) => result.isEmpty ? null : result.first);

  @override
  void delete(entity) {
    if (_disposed) throw new StateError('The session have been disposed');
    if (entityId(entity) == null) throw new ArgumentError('The entity is not known by the session');

    queue.add(new DbOperation()
      ..id = entityId(entity)
      ..type = OperationType.delete
      ..entity = entity
    );
  }

  @override
  void store(entity) {
    if (_disposed) throw new StateError('The session have been disposed');
    var operation;

    if (entityId(entity) == null) {
      defaultValidator(entity, true);
      operation = OperationType.create;
    } else {
      defaultValidator(entity, false);
      operation = OperationType.update;
    }

    queue.add(new DbOperation()
      ..id = entityId(entity)
      ..type = operation
      ..entity = entity
    );
  }

  @override
  Future saveChanges() async {
    if (_disposed) throw new StateError('The session have been disposed');
    await writeQueue();

    for (var operation in queue) {
      if (operation.type == OperationType.create) {
        attach(operation.entity, operation.id);
      }

      operations.add(operation);
    }
    queue.clear();
  }

  /// Function to implement when developing an adapter.
  ///
  /// Should persist the queue to the database and  set the id of all created
  /// entities on the corresponding operation.
  Future writeQueue();

  @override
  void registerCompanion(Type type, Companion companion) {
    companions[type] = companion(this);
  }

}
