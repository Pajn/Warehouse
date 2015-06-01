part of warehouse.sql;

abstract class SqlDbSession<T extends SqlDb> implements DbSession<T> {
  factory SqlDbSession(SqlDb db) => new SqlDbSessionImplementation(db);
}
