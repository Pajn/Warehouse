part of warehouse.sql;

abstract class SqlDb extends SqlEndpoint {
  Map<Type, Table> get modelTypes;
  Set<Table> get tables;
  Map<Type, String> get dataTypes;

  void registerModel(Type type, {List<Type> subtypes});
  Future createTables();
  Future<SqlTransaction> startTransaction();
}

abstract class SqlTransaction extends SqlEndpoint {
  Future<List> commit();
  Future rollback();
}
