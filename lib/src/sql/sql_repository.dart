part of warehouse.sql;

abstract class SqlRepository<T> extends Repository<T> {
  SqlDbSession<SqlDb> get session;
  String get table;

  factory SqlRepository(SqlDbSession session) =>
      new SqlRepositoryImplementation(session);

  factory SqlRepository.withTypes(SqlDbSession session, List<Type> types) =>
      new SqlRepositoryImplementation.withTypes(session, types);
}
