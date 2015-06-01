part of warehouse.sql;

abstract class SqlQuery<T extends SqlQuery> implements Future {
  /// Executes the query and return the result
  Future execute({List parameters, returnCreated: false});

  /// Executes the query and returns the value
  Future then(onValue(value), {Function onError});

  T copy();
  String toString();
}

abstract class Filter<T extends Filter> {
  /// Filter the query to records that have the specified properties
  /// [Matchers]
  ///
  /// Overrides [whereClause]
  T where(Map properties);

  /// Specify a custom WHERE clause
  ///
  /// Overridden by [where]
  T whereClause(String clause);

  /// Limit the result to [amount] number of records
  T limit(int amount);

  /// Skip [amount] number of records
  T offset(int amount);
}

abstract class InsertQuery implements SqlQuery<InsertQuery> {
  /// Specify the table of the new record
  InsertQuery into(String tableName);

  /// Specify what fields that will be inserted
  ///
  /// Overridden by [content]
  InsertQuery fields(List<String> fields);

  /// Specify which values will be inserted
  ///
  /// Overridden by [content]
  InsertQuery values(List values);

  /// Set the new content of the record
  ///
  /// Overrides [fields] and [values]
  InsertQuery content(Map<String, dynamic> content);

  @override
  Future<int> execute({List parameters, returnCreated: true});
}

abstract class SelectQuery implements SqlQuery, Filter<SelectQuery> {
  /// Specify a target for this query, usually a table
  SelectQuery from(String target);

  /// Specify a column to sort on
  SelectQuery orderBy(String column);

  /// Specify fields to join on
  ///
  /// To join using other id:
  /// `{thisColumn: otherTable}`
  /// To join using this id:
  /// `{thisColumn: !otherTable}`
  SelectQuery join(Map<String, String> fieldTable);

  /// Executes the query and return all records
  Future<List<Map>> all({List parameters});

  /// Executes the query and return the first record in the result
  ///
  /// NOTE: This does NOT limit the query, do that with the limit
  /// method on [Filter] queries
  Future<Map> one({List parameters});

  /// Executes the query and return the results in [column]
  ///
  /// If [column] is not specified the first column will be used.
  ///
  /// NOTE: This does NOT limit nor alter the projections of the query,
  /// do that with the limit method on [Filter] queries and projections
  /// argument on [SelectQuery] constructor.
  Future<List> column({String column, List parameters});

  /// Executes the query and return the result in the first record in [column]
  ///
  /// If [column] is not specified the first column will be used.
  ///
  /// NOTE: This does NOT limit nor alter the projections of the query,
  /// do that with the limit method on [Filter] queries and projections
  /// argument on [SelectQuery] constructor.
  Future scalar({String column, List parameters: const []});
}

abstract class UpdateQuery implements SqlQuery, Filter<UpdateQuery> {
  /// Specify fields to update
  UpdateQuery set(Map<String, dynamic> fields);
}

abstract class DeleteQuery implements SqlQuery, Filter<DeleteQuery> {
  /// Specify a target for this query, usually a table
  DeleteQuery from(String target);
}
