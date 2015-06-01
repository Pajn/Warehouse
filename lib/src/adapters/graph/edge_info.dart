part of warehouse.graph.adapter;

class EdgeInfo {
  /// The id of the edge itself
  final edgeId;
  /// Id of the node the edge goes to
  final headId;

  EdgeInfo(this.edgeId, this.headId);
}
