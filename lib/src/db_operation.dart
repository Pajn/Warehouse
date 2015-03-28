part of warehouse;

enum OperationType {
  create, delete, update
}

class DbOperation<T> {
  var id;
  OperationType operation;
  T entity;
}
