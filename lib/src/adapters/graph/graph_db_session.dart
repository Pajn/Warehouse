part of warehouse.graph.adaper;

abstract class GraphDbSessionBase<T> extends DbSessionBase<T> with GraphDbSession {
  final edges = new Expando<Map<Symbol, List<EdgeInfo>>>();

  @override
  void attach(entity, id) {
    super.attach(entity, id);

    var info = new HashMap();
    var il = lookingGlass.lookOnObject(entity);

    il.relations.forEach((name, edge) {
      // todo: Maybe attach edges?
      info[name] = [];
    });

    edges[entity] = info;
  }

  void detach(entity) {
    super.detach(entity);
    edges[entity] = null;
  }

  void attachEdge(entity, String label, edgeId, endId) {
    edges[entity][label].add(new EdgeInfo(edgeId, endId));
  }

  @override
  void store(entity) {
    var isNew = entityId(entity) == null;

    super.store(entity);

    var il = lookingGlass.lookOnObject(entity);

    var relationsToKeep = new HashMap();

    var relations = il.relations;
    relations.forEach((name, relation) {
      if (relation == null) {
        if (!isNew && edges[entity][name].isNotEmpty) {
          // The node exists, and had relations that is now removed
          edges[entity][name].forEach((info) => deleteEdge(entity, name, info.edgeId));
        }
      } else if (relation is List) {
        relation.forEach((relation) {
          if (isNew || !hasEdge(edges[entity][name], relation)) {
            storeRelation(entity, name, relation);
          }
        });

        relationsToKeep[name] = relation;
      } else if (isNew || !edges[entity][name].contains(entityId(relation))) {
        storeRelation(entity, name, relation);
        if (!isNew && edges[entity][name].isNotEmpty) {
          // The node exists, and had relations that is now replaced
          edges[entity][name].forEach((info) => deleteEdge(entity, name, info.edgeId));
        }
      }
    });

    if (!isNew) {
      // Delete all edges that exists and is not in relationsToKeep
      relationsToKeep.forEach((name, List list) {
        edges[entity][name]
          .where((info) => list.every((relatedEntity) {
            if (isEdgeClass(relatedEntity.runtimeType)) {
              return info.edgeId != entityId(relatedEntity);
            } else {
              return info.endId != entityId(relatedEntity);
            }
          }))
          .forEach((info) => deleteEdge(entity, name, info.edgeId));
      });
    }
  }

  deleteEdge(start, name, edgeId) {
    queue.add(new DeleteEdgeOperation()
      ..type = OperationType.delete
      ..id = edgeId
    );
  }

  storeRelation(start, name, relatedEntity) {
    var edgeEntity;
    var endEntity;

    if (isEdgeClass(relatedEntity.runtimeType)) {
      edgeEntity = relatedEntity;

      // TODO: Find end node
      throw 'not implemented';
    } else {
      endEntity = relatedEntity;
    }

    if (
        entityId(endEntity) == null &&
        queue
          .where((op) => op.type == OperationType.create)
          .every((op) => !identical(op.entity, endEntity))
    ) {
      throw new StateError('The end of a relation must be stored first');
    }

    queue.add(new EdgeOperation()
      ..type = OperationType.create
      ..entity = edgeEntity
      ..startNode = start
      ..endNode = endEntity
      ..label = name
    );
  }

  @override
  Future saveChanges() async {
    await writeQueue();

    for (var operation in queue) {
      if (operation.type == OperationType.create && operation.entity != null) {
        attach(operation.entity, operation.id);
      } else if (operation.type == OperationType.create && operation is EdgeOperation) {
        attachEdge(operation.startNode, operation.label, operation.id, entityId(operation.endNode));
      } else if (operation.type == OperationType.delete && operation.entity != null) {
        detach(operation.entity);
      }

      operations.add(operation);
    }
    queue.clear();
  }

  @override
  Future find(Map where, {List<Type> types, depth: 1}) =>
    findAll(where: where, limit: 1, types: types, depth: depth)
      .then((result) => result.isEmpty ? null : result.first);

  hasEdge(List<EdgeInfo> edgeInfo, relatedEntity) {
    if (isEdgeClass(relatedEntity.runtimeType)) {
      return edgeInfo.any((info) => info.edgeId == entityId(relatedEntity));
    } else {
      return edgeInfo.any((info) => info.endId == entityId(relatedEntity));
    }
  }
}
