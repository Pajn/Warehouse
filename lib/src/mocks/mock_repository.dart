part of warehouse.mocks;

var _lg = new LookingGlass();

/// A [Repository] for tests.
///
/// An implementation of [Repository] using an in-memory [Map], useful in tests.
class MockRepository<T> extends RepositoryBase<T> {
  @override
  final MockSession session;

  MockRepository(MockSession session) : this.session = session, super(session);
  MockRepository.withTypes(MockSession session, List<Type> types)
    : this.session = session,
      super(session, types: types);

  @override
  Future<int> countAll({Map where, List<Type> types}) async {
    return session.db.values
      .where((entity) {
        List ts = (types == null) ? this.types : types;
        return ts.any((t) => isSubtype(entity, t));
      })
      .where(matches(where))
      .length;
  }

  @override
  Future deleteAll({Map where}) async {
    var toDelete = [];
    session.db.forEach((id, entity) {
      if (types.any((t) => isSubtype(entity, t)) && matches(where)(entity)) {
        toDelete.add(id);
      }
    });

    toDelete.forEach(session.db.remove);
  }

  @override
  Future<List<T>> findAll({Map where, int skip: 0, int limit: 50, String sort, List<Type> types}) async {
    var result = session.db.values
      .where((entity) {
        List ts = (types == null) ? this.types : types;
        return ts.any((t) => isSubtype(entity, t));
      })
      .where(matches(where))
      .skip(skip)
      .take(limit)
      .toList();

    if (sort != null) {
      result.sort((a, b) {
        var ila = _lg.lookOnObject(a);
        var ilb = _lg.lookOnObject(b);

        return ila.properties[sort].compareTo(ilb.properties[sort]);
      });
    }

    return result;
  }

  @override
  Future<T> get(id) async {
    return session.db[id];
  }

  @override
  Future<List<T>> getAll(Iterable ids) async {
    return ids.map((id) => session.db[id]).toList();
  }
}
