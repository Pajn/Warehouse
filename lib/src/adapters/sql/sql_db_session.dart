part of warehouse.sql.adapter;

class SqlDbSessionImplementation<T extends SqlDb> extends DbSessionBase<T>
    with SqlDbSession<T> {
  /// Holds the status of all relations from entities
  final relations = new Expando<Map<Symbol, List<RelationInfo>>>();
  final SqlDb db;
  final lookingGlass = new LookingGlass(
      supportLists: false,
      convertedTypes: const {
    DateTime: timestampConverter,
    GeoPoint: geoPointStringConverter,
    Type: typeConverter,
  });

  @override
  final supportsListsAsProperty = false;

  SqlDbSessionImplementation(this.db);

  @override
  void attach(entity, id) {
    super.attach(entity, id);

    var info = new HashMap();
    var il = lookingGlass.lookOnObject(entity);

    il.relations.forEach((name, related) {
      var relations = [];
      if (related is List) {
        relations = related
            .where((related) => entityId(related) != null)
            .map((related) =>
                new RelationInfo(entityId(related), tableFor(related).name))
            .toList();
      }
      info[name] = relations;
    });

    relations[entity] = info;
  }

  void attachRelation(toEntity, String toColumn, String fromTable, fromId) {
    relations[toEntity][toColumn].add(new RelationInfo(fromId, fromTable));
  }

  @override
  void detach(entity) {
    super.detach(entity);
    relations[entity] = null;
  }

  @override
  void store(entity) {
    if (disposed) throw new StateError('The session have been disposed');
    var isNew = entityId(entity) == null;
    super.store(entity);

    if (isNew) {
      var info = new HashMap();
      var cl = lookingGlass.lookOnClass(entity.runtimeType);

      cl.relationalFields.forEach((name, _) {
        info[MirrorSystem.getName(name)] = [];
      });

      relations[entity] = info;
    }

    updateRelations(entity);
  }

  void updateRelations(entity) {
    var isNew = entityId(entity) == null;
    var il = lookingGlass.lookOnObject(entity);

    var relationsToKeep = new HashMap();

    var relations = il.relations;
    relations.forEach((name, related) {
      if (related == null) {
        if (!isNew &&
            getType(il.cl.relationalFields[MirrorSystem.getSymbol(name)])
                .isSubtypeOf(list)) {
          // The entity exists, and had relations that is now removed
          this.relations[entity][name].forEach((info) =>
              deleteRelation(entity, name, info.fromId, info.fromTable));
        }
      } else if (related is List) {
        related.forEach((related) {
          if (isNew ||
              !this.relations[entity][name]
                  .any((id) => id == entityId(related))) {
            storeRelation(entity, name, related);
          }
        });

        relationsToKeep[name] = related;
      }
    });

    if (!isNew) {
      // Delete all edges that exists and is not in relationsToKeep
      relations.forEach((name, _) {
        var list = (relationsToKeep.containsKey(name))
            ? relationsToKeep[name]
            : const [];
        this.relations[entity][name]
            .where((info) => list.every((relatedEntity) {
          return info.fromId != entityId(relatedEntity);
        })).forEach((info) =>
            deleteRelation(entity, name, info.fromId, info.fromTable));
      });
    }
  }

  storeRelation(entity, name, from) {
    queue.add(new SetRelationOperation()
      ..from = from
      ..to = entity
      ..name = name
      ..column = '@${tableFor(entity).name}%$name');
  }

  deleteRelation(entity, name, fromId, fromTable) {
    queue.add(new RemoveRelationOperation()
      ..fromId = fromId
      ..to = entity
      ..name = name
      ..table = fromTable
      ..column = '@${tableFor(entity).name}%$name');
  }

  @override
  Future writeQueue() async {
    SqlTransaction transaction = await db.startTransaction();
    var createdEntities = new HashMap();

    for (var op in queue) {
      if (op is RelationOperation) continue;
      switch (op.type) {
        case OperationType.create:
          createdEntities[op.entity] = op.id = await transaction
              .insert()
              .into(tableFor(op.entity).name)
              .content(serialize(op.entity, createdEntities));

          break;

        case OperationType.update:
          await transaction
              .update(tableFor(op.entity).name)
              .set(serialize(op.entity, createdEntities))
              .where({'id': op.id});

          break;

        case OperationType.delete:
          await transaction
              .delete()
              .from(tableFor(op.entity).name)
              .where({'id': op.id});

          break;
      }
    }

    for (var op in queue) {
      if (op is! RelationOperation) continue;
      if (op is SetRelationOperation) {
        var fromId = entityId(op.from);
        if (fromId == null) {
          fromId = createdEntities[op.from];
        }
        var toId = entityId(op.to);
        if (toId == null) {
          toId = createdEntities[op.to];
        }

        await transaction
            .update(tableFor(op.from).name)
            .set({op.column: toId})
            .where({'id': fromId});

      } else if (op is RemoveRelationOperation) {
        await transaction
            .update(op.table)
            .set({op.column: null})
            .where({'id': op.fromId});
      }
    }

    await transaction.commit();

    for (var op in queue) {
      if (op is! RelationOperation) continue;

      if (op is SetRelationOperation) {
        attachRelation(op.to, op.name, tableFor(op.from).name, op.column);

      } else if (op is RemoveRelationOperation) {
        relations[op.to][op.name]
            .removeWhere((info) => info.fromId == op.fromId);
      }
    }
  }

  Table tableFor(entity) {
    var type = (entity is Type) ? entity : entity.runtimeType;
    return db.modelTypes[type];
  }

  serialize(entity, Map createdEntities) {
    var properties = lookingGlass.lookOnObject(entity).properties;
    var il = lookingGlass.lookOnObject(entity);
    il.relations.forEach((name, related) {
      if (related == null) {
        if (!getType(il.cl.relationalFields[MirrorSystem.getSymbol(name)])
            .isSubtypeOf(list)) {
          properties[name] = null;
        }
      } else if (related is! List) {
        var id = entityId(related);
        if (id == null) {
          id = createdEntities[related];
        }
        properties[name] = id;
      }
    });
    properties['@labels'] = ':${findLabels(entity.runtimeType).join(':')}:';
    properties['@type'] = typeConverter.toDatabase(entity.runtimeType);
    return properties;
  }
}
