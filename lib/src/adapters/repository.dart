part of warehouse.adapter;

/// Class to be inherited when developing an adapter
abstract class RepositoryBase<T> extends Repository<T> {
  List<Type> _types;
  List<Type> get types => (T == dynamic) ? _types : [T];

  RepositoryBase(DbSession session, {List<Type> types}) :
    this._types = types, super(session) {
    if (T != dynamic && types != null) {
      throw new ArgumentError('types cant be specified if generic type T is set');
    }
    if (T == dynamic && (types == null || types.isEmpty)) {
      throw new ArgumentError('types must be specified if generic type T is not set');
    }
  }

  @override
  Future find(Map where, {List<Type> types}) =>
    findAll(where: where, limit: 1, types: types)
      .then((result) => result.isEmpty ? null : result.first);


}
