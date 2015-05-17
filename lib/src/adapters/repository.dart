part of warehouse.adapter;

/// Class to be inherited when developing an adapter
abstract class RepositoryBase<T> extends Repository<T> {
  List<Type> _types;

  RepositoryBase(DbSession session, [Type type]) : super(session) {
    if (T != dynamic && type != null) {
      throw new ArgumentError('type cant be specified if generic type T is set');
    }
    _types = (type == null) ? [T] : [type];
  }

  @override
  Future find(Map where, {List<Type> types}) =>
    findAll(where: where, limit: 1, types: types)
      .then((result) => result.isEmpty ? null : result.first);

  List<Type> get types => _types;

}
