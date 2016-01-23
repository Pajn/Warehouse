part of warehouse.adapter;

final list = reflectType(List);

/// A wrapper around [dart:mirrors] to simply serializing and deserializing objects
///
/// This class contains rules for how properties and objects should be (de)serialized.
class LookingGlass {
  final bool supportLists;
  /// List of types that the database handles natively and does not need a conversation
  ///
  /// Note: If JSON is used to communicate with the database, these types are usually limited
  /// by what types [JSON.encode] supports and not by the database.
  final List<Type> nativeTypes;
  /// Map of types and [Converter]s for types that is supported but need conversation.
  final Map<Type, Converter> convertedTypes;

  /// Holds generated id for document serialization
  final Expando entities = new Expando();
  final uuid = new Uuid();

  LookingGlass({
      this.supportLists: true,
      this.nativeTypes: const [ String, num, bool ],
      this.convertedTypes: const {
        DateTime: timestampConverter,
        GeoPoint: geoPointArrayConverter,
        Type: typeConverter,
      }
  });

  /// Checks if the [type] is supported as a property,
  /// either by beeing in [nativeTypes] or [convertedTypes]
  supportsTypeAsProperty(ClassMirror classMirror) {
    if (classMirror.isSubtypeOf(list)) {
      if (classMirror.typeArguments.first == currentMirrorSystem().dynamicType) {
        throw 'Lists must be typed to contain a specific type';
      }
      classMirror = classMirror.typeArguments.first;
    }
    if (nativeTypes.any((type) => classMirror.isAssignableTo(reflectType(type)))) {
      return true;
    }
    return convertedTypes.keys.any((type) => classMirror.isAssignableTo(reflectType(type)));
  }

  Converter converterFor(ClassMirror classMirror) {
    var type = convertedTypes.keys.firstWhere((type) =>
      classMirror.isAssignableTo(reflectType(type)), orElse: () => null);

    if (type == null) return null;
    return convertedTypes[type];
  }

  /// Create a [ClassLens] on [type]
  ClassLens lookOnClass(Type type) => new ClassLens(type, this);
  /// Create an [InstanceLens] on [object]
  InstanceLens lookOnObject(Object object) => new InstanceLens.fromObject(object, this);

  /// Helper for serializing a document (all related objects are serialized as direct children)
  Map<String, dynamic> serializeDocument(Object entity, {
      bool generateId: false,
      bool includeLabels: true
  }) {
    var il = lookOnObject(entity);
    var document = il.serialize(includeLabels: includeLabels);

    if (generateId) {
      var id = entities[entity];

      if (id == null) {
        id = uuid.v1();
        entities[entity] = id;
      }

      document['@id'] = id;
    }


    il.relations.forEach((name, relation) {
      if (relation is Iterable) {
        document[name] = relation.map(_serializeDocumentWithId).toList();
      } else if (relation != null) {
        document[name] = _serializeDocumentWithId(relation);
      }
    });
    return document;
  }

  _serializeDocumentWithId(Object entity) =>
      serializeDocument(entity, generateId: true);

  /// Helper for deserializing a document (all related objects are serialized as direct children)
  Object deserializeDocument(Map<String, dynamic> document, {
      returnInstanceLens: false,
      DbSession session,
      Map cache
  }) {
    if (cache == null) {
      cache = new HashMap();
    }

    var il;

    if (document.containsKey('@id')) {
      if (cache.containsKey(document['@id'])) {
        il = cache[document['@id']];
      } else {
        il = new InstanceLens.deserialize(document, this);
        cache[document['@id']] = il;
      }
    } else {
      il = new InstanceLens.deserialize(document, this);
    }

    if (document.containsKey('id')) {
      setId(il, document['id']);
      if (session != null) {
        session.attach(il.instance, document['id']);
      }
    }

    document.forEach((property, value) {
      if (value == null) return;
      if (il.cl.relationalFields.containsKey(MirrorSystem.getSymbol(property))) {
        deserializeNested(value) {
          if (value is Map) {
            il.setRelation(property, deserializeDocument(value,
                returnInstanceLens: true,
                session: session,
                cache: cache
            ));
          }
        }

        if (value is List) {
          value.forEach(deserializeNested);
        } else {
          deserializeNested(value);
        }
      }
    });

    return returnInstanceLens ? il : il.instance;
  }

  /// Set the id field on [entity] if it exist
  void setId(entity, id) {
    if (entity is! InstanceLens) {
      entity = lookOnObject(entity);
    }
    if (entity.cl.idField != null) {
      entity.im.setField(#id, id);
    }
  }
}
