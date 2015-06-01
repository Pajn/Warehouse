part of warehouse.mocks;

/// A [DbSession] for tests.
///
/// An implementation of [DbSession] using an in-memory [Map], useful in tests.
class MockSession extends DbSessionBase {
  @override
  final supportsListsAsProperty = true;
  @override
  final Map db = {};
  int _currentId = 0;

  @override
  LookingGlass get lookingGlass => new LookingGlass();

  getNextId() => (_currentId++).toString();

  @override
  Future writeQueue() async {
    for (var op in queue) {
      switch (op.type) {
        case OperationType.create:
          op.id = getNextId();
          db[op.id] = op.entity;
          break;
        case OperationType.update:
          db[op.id] = op.entity;
          break;
        case OperationType.delete:
          db.remove(op.id);
          break;
      }
    }
  }
}
