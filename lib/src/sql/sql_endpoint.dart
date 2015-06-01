part of warehouse.sql;

typedef MatchVisitor(Matcher matcher, List parameters, LookingGlass lg);

abstract class SqlEndpoint {
  final String escapeChar = '`';
  final Map<Type, MatchVisitor> matchers = const {};
  final lg = new LookingGlass(supportLists: false);

  InsertQuery insert() => new InsertQueryImplementation(this);

  SelectQuery select([List<String> projections = const []]) =>
      new SelectQueryImplementation(this, projections);

  UpdateQuery update(String projection) =>
      new UpdateQueryImplementation(this, projection);

  DeleteQuery delete() => new DeleteQueryImplementation(this);

  Future sql(String sql, {List parameters, bool returnCreated: false});
}
