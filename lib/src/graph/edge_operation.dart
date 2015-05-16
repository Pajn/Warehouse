part of warehouse.graph;

class EdgeOperation extends DbOperation {
  String label;
  /// The node the edge starts from
  var tailNode;
  /// The node the edge leaves from
  var headNode;
}

class DeleteNodeOperation extends DbOperation {
  final type = OperationType.delete;
  /// If [deleteEdges] is not set the deletion will be rejected if [entity] still
  /// have edges to or from it. If it's set the edges will be deleted as well.
  bool deleteEdges = false;
}
