part of warehouse.sql;

abstract class RelationOperation extends DbOperation {
  String column;
  String name;
  var to;
}

class SetRelationOperation extends RelationOperation {
  var from;
}

class RemoveRelationOperation extends RelationOperation {
  String table;
  var fromId;
}
