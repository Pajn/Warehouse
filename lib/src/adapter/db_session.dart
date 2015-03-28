part of warehouse.adapter;

/// Class to be inherited when developing an adapter
abstract class DbSessionBase extends DbSession {

  /// All entities known by the session
  final Expando entities = new Expando();

  /// Queue to be persisted when [saveChanges] is called
  final List<DbOperation> queue = [];

  /// Controls the [onOperation] stream, all persisted operations in the [queue] is added here.
  final StreamController<DbOperation> operations = new StreamController.broadcast();

  @override
  final Map<Type, dynamic> companions = new HashMap();

  @override
  Stream<DbOperation> get onOperation => operations.stream;

  @override
  entityId(entity) => entities[entity];

  @override
  void attach(entity, id) => entities[entity] = id;

  @override
  Future find(Map where, {Type type}) =>
    findAll(where: where, limit: 1, type: type)
      .then((result) => result.isEmpty ? null : result.first);

  @override
  void delete(entity) {
    if (entityId(entity) == null) throw 'The entity is not known by the session';

    queue.add(new DbOperation()
      ..id = entityId(entity)
      ..operation = OperationType.delete
      ..entity = entity
    );
  }

  @override
  void store(entity) {
    var operation;

    // TODO: Validate entity

    if (entityId(entity) == null) {
      operation = OperationType.create;
    } else {
      operation = OperationType.update;
    }

    queue.add(new DbOperation()
      ..id = entityId(entity)
      ..operation = operation
      ..entity = entity
    );
  }

  @override
  Future saveChanges() async {
    await writeQueue();

    queue.forEach(operations.add);
    queue.clear();
  }

  /// Function to implement when developing an adapter.
  ///
  /// Should persist the queue to the database and attach all created entities with there id by
  /// calling [attach]
  Future writeQueue();

  @override
  void registerCompanion(Type type, Companion companion) {
    companions[type] = companion(this);
  }
}
