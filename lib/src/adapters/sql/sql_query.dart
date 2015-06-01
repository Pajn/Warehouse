part of warehouse.sql.adapter;

abstract class SqlQueryImplementation<T extends SqlQuery>
    implements SqlQuery<T> {
  final SqlEndpoint db;
  var parameters_ = [];

  SqlQueryImplementation(this.db);

  @override
  Future execute({List parameters, returnCreated: false}) {
    if (parameters is List) {
      parameters_.addAll(parameters);
    }

    return db.sql(toString(),
        parameters: parameters_, returnCreated: returnCreated);
  }

  @override
  Future then(onValue(value), {Function onError}) =>
      execute().then(onValue, onError: onError);

  @override
  Future catchError(Function onError, {bool test(Object error)}) =>
      execute().catchError(onError, test: test);

  @override
  Future whenComplete(action()) => execute().whenComplete(action);

  @override
  Stream asStream() => execute().asStream();

  @override
  Future timeout(Duration timeLimit, {onTimeout()}) =>
      execute().timeout(timeLimit, onTimeout: onTimeout);

  T copy();
  String toString();
}

abstract class FilterImplementation<T extends FilterImplementation>
    implements Filter<T> {
  SqlEndpoint get db;

  var where_ = {};
  var whereClause_;
  var limit_;
  var offset_;

  @override
  T where(Map properties) {
    if (properties != null) {
      where_.addAll(properties);
    }
    return this;
  }

  @override
  T whereClause(String clause) {
    whereClause_ = clause;
    return this;
  }

  @override
  T limit(int amount) {
    limit_ = amount;
    return this;
  }

  @override
  T offset(int amount) {
    offset_ = amount;
    return this;
  }

  writeWhere_(StringBuffer sb, List parameters, {String prefix}) {
    if (whereClause_ == null && where_.isNotEmpty) {
      whereClause_ = buildWhereClause(where_, parameters, prefix, db);
    }
    if (whereClause_ != null) {
      sb.write(' WHERE ');
      sb.write(whereClause_);
    }
  }

  writeLimit_(StringBuffer sb) {
    if (limit_ != null) {
      sb.write(' LIMIT ');
      sb.write(limit_);
    }
  }
}

class InsertQueryImplementation extends SqlQueryImplementation<InsertQuery>
    implements InsertQuery {
  var into_;
  var fields_;
  var values_;

  InsertQueryImplementation(SqlEndpoint db) : super(db);

  @override
  InsertQuery into(String tableName) {
    into_ = tableName;
    return this;
  }

  @override
  InsertQuery fields(List<String> fields) {
    fields_ = fields;
    return this;
  }

  @override
  InsertQuery values(List values) {
    values_ = values;
    return this;
  }

  @override
  InsertQuery content(Map<String, dynamic> content) {
    fields_ = content.keys;
    values_ = content.values;
    return this;
  }

  @override
  InsertQuery copy() => new InsertQueryImplementation(db)
    ..into_ = into_
    ..fields_ = fields_
    ..values_ = values_;

  String toString() {
    var sb = new StringBuffer('INSERT INTO ');

    sb.write(db.escapeChar);
    sb.write(into_);
    sb.write(db.escapeChar);

    sb.write('(');
    sb.write(db.escapeChar);
    sb.writeAll(fields_, '${db.escapeChar}, ${db.escapeChar}');
    sb.write(db.escapeChar);
    sb.write(') VALUES (');

    var first = true;
    for (var value in values_) {
      if (first) {
        first = false;
        sb.write('?');
      } else {
        sb.write(', ?');
      }
      parameters_.add(value);
    }

    sb.write(')');

    return sb.toString();
  }

  @override
  Future<int> execute({List parameters, returnCreated: true}) =>
      super.execute(parameters: parameters, returnCreated: returnCreated);
}

class SelectQueryImplementation extends SqlQueryImplementation
    with FilterImplementation<SelectQueryImplementation>
    implements SelectQuery {
  var projections_;
  var from_;
  var orderBy_;
  Map<String, String> join_;

  SelectQueryImplementation(SqlEndpoint db, List<String> projections)
      : super(db) {
    projections_ = projections;
  }

  @override
  SelectQuery from(String target) {
    from_ = target;
    return this;
  }

  @override
  SelectQuery orderBy(String column) {
    orderBy_ = column;
    return this;
  }

  @override
  SelectQuery join(Map<String, String> fieldTable) {
    join_ = fieldTable;
    return this;
  }

  @override
  SelectQuery copy() => new SelectQueryImplementation(db, projections_)
    ..from_ = from_
    ..orderBy_ = orderBy_
    ..join_ = join_
    ..where_ = where_
    ..whereClause_ = whereClause_
    ..limit_ = limit_
    ..offset_ = offset_;

  String toString() {
    var sb = new StringBuffer('SELECT ');
    if (projections_.isEmpty) {
      sb.write('*');
    } else {
      sb.writeAll(projections_, ', ');
    }
    sb.write(' FROM ');
    if (limit_ != null && join_ != null) {
      sb.write('(SELECT * FROM ');
      sb.write(db.escapeChar);
      sb.write(from_);
      sb.write(db.escapeChar);

      writeWhere_(sb, parameters_, prefix: from_);

      if (orderBy_ != null) {
        sb.write(' ORDER BY ');
        sb.write(db.escapeChar);
        sb.write(orderBy_);
        sb.write(db.escapeChar);
      }

      sb.write(' LIMIT ');
      sb.write(limit_);

      sb.write(') as ');
    }
    sb.write(db.escapeChar);
    sb.write(from_);
    sb.write(db.escapeChar);

    if (join_ != null) {
      join_.forEach((field, table) {
        if (table.startsWith('!')) {
          table = '${db.escapeChar}${table.substring(1)}${db.escapeChar}';
          sb.write(
              ' LEFT JOIN $table as ${db.escapeChar}$field${db.escapeChar} ON ${db.escapeChar}$from_${db.escapeChar}.id = ${db.escapeChar}$field${db.escapeChar}.${db.escapeChar}@$from_%$field${db.escapeChar}');
        } else {
          sb.write(
              ' LEFT JOIN ${db.escapeChar}$table${db.escapeChar} as ${db.escapeChar}$field${db.escapeChar} ON ${db.escapeChar}$from_${db.escapeChar}.${db.escapeChar}$field${db.escapeChar} = ${db.escapeChar}$field${db.escapeChar}.id');
        }
      });
    }

    if (join_ == null) {
      writeWhere_(sb, parameters_, prefix: from_);

      if (orderBy_ != null) {
        sb.write(' ORDER BY ');
        sb.write(db.escapeChar);
        sb.write(orderBy_);
        sb.write(db.escapeChar);
      }

      writeLimit_(sb);
    }

    return sb.toString();
  }

  @override
  Future<List<Map>> all({List parameters}) => execute(parameters: parameters);

  @override
  Future<Map> one({List parameters}) => all(parameters: parameters)
      .then((result) => (result.length > 0) ? result.first : null);

  @override
  Future<List> column({String column, List parameters}) => all(
          parameters: parameters)
      .then((result) => result.map(_column(column)).toList());

  @override
  Future scalar({String column, List parameters: const []}) =>
      one(parameters: parameters).then(_column(column));

  _column(String column) => column == null
      ? (Map row) => row[row.keys.first]
      : (Map row) => row[column];
}

class UpdateQueryImplementation extends SqlQueryImplementation
    with FilterImplementation<UpdateQueryImplementation>
    implements UpdateQuery {
  final String projection;
  var set_ = {};

  UpdateQueryImplementation(SqlEndpoint db, this.projection) : super(db);

  @override
  UpdateQuery set(Map<String, dynamic> fields) {
    set_.addAll(fields);
    return this;
  }

  @override
  UpdateQuery copy() => new UpdateQueryImplementation(db, projection)
    ..set_ = set_
    ..where_ = where_
    ..whereClause_ = whereClause_
    ..limit_ = limit_
    ..offset_ = offset_;

  String toString() {
    var sb = new StringBuffer('Update ');
    sb.write(db.escapeChar);
    sb.write(projection);
    sb.write(db.escapeChar);

    sb.write(' SET ');

    var index = 0;
    set_.forEach((key, value) {
      if (index > 0) {
        sb.write(', ');
      }

      sb.write(db.escapeChar);
      sb.write(key);
      sb.write(db.escapeChar);
      sb.write(' = ?');
      parameters_.add(value);

      index++;
    });

    writeWhere_(sb, parameters_);
    writeLimit_(sb);

    return sb.toString();
  }
}

class DeleteQueryImplementation extends SqlQueryImplementation
    with FilterImplementation<DeleteQueryImplementation>
    implements DeleteQuery {
  var from_;

  DeleteQueryImplementation(SqlEndpoint db) : super(db);

  @override
  DeleteQuery from(String target) {
    from_ = target;
    return this;
  }

  @override
  DeleteQuery copy() => new DeleteQueryImplementation(db)
    ..from_ = from_
    ..where_ = where_
    ..whereClause_ = whereClause_
    ..limit_ = limit_
    ..offset_ = offset_;

  String toString() {
    var sb = new StringBuffer('DELETE FROM ');
    sb.write(db.escapeChar);
    sb.write(from_);
    sb.write(db.escapeChar);

    writeWhere_(sb, parameters_);
    writeLimit_(sb);

    return sb.toString();
  }
}
