part of warehouse.graph.adaper;

class GraphDbSessionBase<T> extends DbSessionBase<T> with GraphDbSession {

  @override
  void store(entity) {
    var isNew = entityId(entity) == null;

    super.store(entity);

    var il = lookingGlass.lookOnObject(entity);

    var edges = il.relations;
    edges.forEach((name, edge) {
      if (edge == null) return;

      var edgeNode;
      var endNode;

      if (isEdgeClass(edge.runtimeType)) {
        edgeNode = edge;

        // TODO: Find end node
        throw 'net implemented';
      } else {
        endNode = edge;
      }

      if (entityId(edge) == null) {
        queue.add(new EdgeOperation()
          ..type = OperationType.create
          ..entity = edgeNode
          ..startNode = entity
          ..endNode = endNode
          ..label = name
        );
      }
    });
  }

  @override
  Future find(Map where, {Type type, depth: 1}) =>
    findAll(where: where, limit: 1, type: type, depth: depth)
      .then((result) => result.isEmpty ? null : result.first);

}
