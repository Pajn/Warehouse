part of warehouse.graph.adaper;

abstract class GraphDbSessionBase<T> extends DbSessionBase<T> with GraphDbSession {
  /// Holds the status of all relations from entities
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

  @override
  void detach(entity) {
    super.detach(entity);
    edges[entity] = null;
  }

  /// Attaches an edge, should be called by adapters when an entity that have relations is
  /// instantiated due to a reading query. Should be called even though the relation have no
  /// [Edge] object.
  void attachEdge(tailNode, String label, edgeId, headId) {
    edges[tailNode][label].add(new EdgeInfo(edgeId, headId));
  }

  @override
  void delete(entity, {bool deleteEdges: false}) {
    if (disposed) throw new StateError('The session have been disposed');
    if (entityId(entity) == null) throw new ArgumentError('The entity is not known by the session');

    if (isEdgeClass(entity.runtimeType)) {
      queue.add(new EdgeOperation()
        ..id = entityId(entity)
        ..type = OperationType.delete
        ..entity = entity
      );
    } else {
      queue.add(new DeleteNodeOperation()
        ..id = entityId(entity)
        ..deleteEdges = deleteEdges
        ..entity = entity
      );
    }
  }

  @override
  void store(entity) {
    if (disposed) throw new StateError('The session have been disposed');
    if (isEdgeClass(entity.runtimeType)) {
      var isNew = entityId(entity) == null;

      if (isNew) {
        throw new ArgumentError(
            'To create an edge you must store the tail node (the node the relation starts from)'
        );
      } else {
        defaultValidator(entity, false);

        queue.add(new EdgeOperation()
          ..id = entityId(entity)
          ..type = OperationType.update
          ..entity = entity
        );
      }
    } else {
      super.store(entity);
      updateRelations(entity);
    }
  }

  /// Only updates relations from a node (creates new, deletes old edges).
  ///
  /// No modifications are done on the node itself.
  updateRelations(node) {
    var isNew = entityId(node) == null;
    var il = lookingGlass.lookOnObject(node);

    var relationsToKeep = new HashMap();

    var relations = il.relations;
    relations.forEach((name, relation) {
      if (relation == null) {
        if (!isNew && edges[node][name].isNotEmpty) {
          // The node exists, and had relations that is now removed
          edges[node][name].forEach((info) => deleteEdge(node, name, info.edgeId));
        }
      } else if (relation is List) {
        relation.forEach((relation) {
          if (isNew || !hasEdge(edges[node][name], relation)) {
            storeRelation(node, name, relation);
          }
        });

        relationsToKeep[name] = relation;
      } else if (isNew || !edges[node][name].contains(entityId(relation))) {
        storeRelation(node, name, relation);
        if (!isNew && edges[node][name].isNotEmpty) {
          // The node exists, and had relations that is now replaced
          edges[node][name].forEach((info) => deleteEdge(node, name, info.edgeId));
        }
      }
    });

    if (!isNew) {
      // Delete all edges that exists and is not in relationsToKeep
      relations.forEach((name, _) {
        var list = (relationsToKeep.containsKey(name)) ? relationsToKeep[name] : const [];
        edges[node][name]
          .where((info) => list.every((relatedEntity) {
            if (isEdgeClass(relatedEntity.runtimeType)) {
              return info.edgeId != entityId(relatedEntity);
            } else {
              return info.headId != entityId(relatedEntity);
            }
          }))
          .forEach((info) => deleteEdge(node, name, info.edgeId));
      });
    }
  }

  deleteEdge(start, name, edgeId) {
    queue.add(new EdgeOperation()
      ..type = OperationType.delete
      ..id = edgeId
      ..label = name
    );
  }

  storeRelation(entity, name, relatedEntity) {
    var tailNode;
    var edgeEntity;
    var headNode;

    if (isEdgeClass(relatedEntity.runtimeType)) {
      edgeEntity = relatedEntity;

      var edgeAnnotation = getEdgeAnnotation(edgeEntity);

      if (!isSubtype(entity, edgeAnnotation.tail)) {
        throw new ArgumentError(
            'To create an edge you must store the tail node (the node the relation starts from)'
        );
      }
      tailNode = entity;
      headNode = lookingGlass.lookOnObject(edgeEntity).relations.values
        .singleWhere((related) => isSubtype(related, edgeAnnotation.head));
    } else {
      tailNode = entity;
      headNode = relatedEntity;
    }

    if (
        entityId(headNode) == null &&
        queue
          .where((op) => op.type == OperationType.create)
          .every((op) => !identical(op.entity, headNode))
    ) {
      throw new StateError(
          'The tail of an edge must be attached or queued for creation '
          'before a relation can be stored'
      );
    }

    queue.add(new EdgeOperation()
      ..type = OperationType.create
      ..entity = edgeEntity
      ..tailNode = tailNode
      ..headNode = headNode
      ..label = name
    );
  }

  @override
  Future saveChanges() async {
    await writeQueue();

    for (var operation in queue) {
      if (operation.type == OperationType.create && operation.entity != null) {
        attach(operation.entity, operation.id);
      }
      if (operation.type == OperationType.create && operation is EdgeOperation) {
        attachEdge(operation.tailNode, operation.label, operation.id, entityId(operation.headNode));
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
      return edgeInfo.any((info) => info.headId == entityId(relatedEntity));
    }
  }
}
