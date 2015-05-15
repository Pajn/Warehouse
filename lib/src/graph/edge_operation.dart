part of warehouse.graph;

class EdgeOperation extends DbOperation {
  String label;
  var startNode;
  var endNode;
}

class DeleteEdgeOperation extends DbOperation {
  final type = OperationType.delete;
}
