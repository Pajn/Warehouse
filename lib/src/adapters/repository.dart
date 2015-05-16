part of warehouse.adapter;

/// Class to be inherited when developing an adapter
abstract class RepositoryBase<T> extends Repository<T> {

  RepositoryBase(DbSession session) : super(session);

  @override
  Future find(Map where, {List<Type> types}) =>
    findAll(where: where, limit: 1, types: types)
      .then((result) => result.isEmpty ? null : result.first);
}
