part of warehouse.sql.adapter;

class SqlRepositoryImplementation<T> extends Repository<T>
    implements SqlRepository<T> {
  final SqlDbSessionImplementation<SqlDb> session;

  String get table => session.tableFor(types.first).name;

  SqlRepositoryImplementation(SqlDbSession session)
      : this.session = session,
        super(session);

  SqlRepositoryImplementation.withTypes(SqlDbSession session, List<Type> types)
      : this.session = session,
        super.withTypes(session, types) {
    if (types != null && types.length != 1) {
      throw new ArgumentError('a SQL repository can only hande a single type');
    }
  }

  @override
  Future<int> countAll({Map where, List<Type> types}) =>
      session.db.select(const ['count(*)']).from(table).where(where).scalar();

  @override
  Future deleteAll({Map where}) =>
      session.db.delete().from(table).where(where).execute();

  @override
  Future find(Map where) => session.db
      .select()
      .from(table)
      .where(where)
      .limit(1)
      .join(foreignKeys())
      .one()
      .then(instantiate);

  @override
  Future<List> findAll(
      {Map where, int skip: 0, int limit: 50, String sort, List<Type> types}) {
    if (types != null) {
      var typesWhere = {'@labels': DO.contain(':${findLabel(types.first)}:')};
      if (where == null) {
        where = typesWhere;
      } else {
        where = new HashMap.from(where)..addAll(typesWhere);
      }
    }

    return session.db
        .select()
        .from(table)
        .where(where)
        .orderBy(sort)
        .limit(limit)
        .offset(skip)
        .all()
        .then(instantiate);
  }

  @override
  Future get(id) => session.db
      .select()
      .from(table)
      .where({'id': id})
      .limit(1)
      .join(foreignKeys())
      .one()
      .then(instantiate);

  @override
  Future<List> getAll(Iterable ids) async {
    ids = ids.map((id) {
      if (id is String) {
        return int.parse(id);
      }
      return id;
    });

    var result = await session.db
        .select()
        .from(table)
        .where({'id': IS.inList(ids)})
        .all()
        .then(instantiate);

    var sorted = [];
    for (var id in ids) {
      sorted.add(result.firstWhere((entity) => id == session.entityId(entity)));
    }
    return sorted;
  }

  instantiate(result) {
    if (result == null) return null;
    if (result is Iterable) {
      return result
          .map((row) =>
              session.lookingGlass.deserializeDocument(row, session: session))
          .toList();
    }

    return session.lookingGlass.deserializeDocument(result, session: session);
  }

  Map foreignKeys() {
    var cl = session.lookingGlass.lookOnClass(types.first);
    var foreign = {};
    cl.relationalFields.forEach((field, dm) {
      var table;
      var type = getType(dm);
      if (type.isSubtypeOf(list)) {
        table = session.tableFor(type.typeArguments.first.reflectedType);
        foreign[MirrorSystem.getName(field)] = '!' + table.name;
      } else {
        table = session.tableFor(type.reflectedType);
        if (table == null) return;
        foreign[MirrorSystem.getName(field)] = table.name;
      }
    });
    return foreign;
  }
}
