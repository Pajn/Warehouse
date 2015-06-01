part of warehouse.sql.adapter;

abstract class SqlDbBase extends SqlDb {
  final Map<Type, Table> modelTypes = new HashMap();
  final Set<Table> tables = new Set.identity();
  final Map<Type, String> dataTypes = {
    int: 'INTEGER',
    num: 'DOUBLE',
    String: 'VARCHAR(255)',
    DateTime: 'BIGINT',
    GeoPoint: 'VARCHAR(255)',
    Type: 'VARCHAR(255)',
  };

  void registerModel(Type type, {List<Type> subtypes}) {
    var hasSubtypes = subtypes != null && subtypes.isNotEmpty;
    var name = findLabel(type);
    var columns = {};

    var cl = lg.lookOnClass(type);
    cl.relationalFields.forEach((field, dm) {
      var fieldType = getType(dm);
      if (fieldType.isSubtypeOf(list)) {
        var columnName = '@$name%${MirrorSystem.getName(field)}';
        var otherType = fieldType.typeArguments.first;
        var table = modelTypes[otherType.reflectedType];
        if (table == null) {
          table = new Table(
              findLabel(otherType), false, {columnName: dataTypes[int]});
          modelTypes[otherType.reflectedType] = table;
        } else {
          table.columns[columnName] = dataTypes[int];
        }
      } else {
        columns[MirrorSystem.getName(field)] = dataTypes[int];
      }
    });
    findColumns(cl, columns);

    columns['@labels'] = dataTypes[String];
    columns['@type'] = dataTypes[Type];

    if (hasSubtypes) {
      for (var type in subtypes) {
        var cl = lg.lookOnClass(type);
        findColumns(cl, columns);
      }
    }

    var table;
    table = new Table(name, hasSubtypes, columns);

    setModelType(type, table);
    tables.add(table);

    if (hasSubtypes) {
      for (var type in subtypes) {
        setModelType(type, table);
      }
    }
  }

  Future createTables() async {
    for (var table in tables) {
      var query = new StringBuffer('CREATE TABLE IF NOT EXISTS ');
      query.write(escapeChar);
      query.write(table.name);
      query.write(escapeChar);
      query.write('(id ${dataTypes[int]} NOT NULL AUTO_INCREMENT, ');
      table.columns.forEach((name, dataType) {
        query.write('`');
        query.write(name);
        query.write('` ');
        query.write(dataType);
        query.write(', ');
      });
      query.write('CONSTRAINT pk PRIMARY KEY (id));');

      await sql(query.toString());
    }
  }

  void setModelType(Type type, Table table) {
    if (modelTypes.containsKey(type)) {
      table.columns.addAll(modelTypes[type].columns);
    }
    modelTypes[type] = table;
  }

  void findColumns(ClassLens cl, Map<String, String> columns) {
    cl.propertyFields.forEach((field, dm) {
      var name = MirrorSystem.getName(field);
      if (!columns.containsKey(name)) {
        var fieldType = getType(dm);
        var dataType =
            dataTypes.keys.firstWhere((type) => isSubtype(fieldType, type));
        columns[name] = dataTypes[dataType];
      }
    });
  }
}
