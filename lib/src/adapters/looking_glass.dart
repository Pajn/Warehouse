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
      if (!supportLists) return false;
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
  Map<String, dynamic> serializeDocument(Object entity) {
    var il = lookOnObject(entity);
    var document = il.serialize();
    il.relations.forEach((name, relation) {
      document[name] = serializeDocument(relation);
    });
    return document;
  }

  /// Helper for deserializing a document (all related objects are serialized as direct children)
  Object deserializeDocument(Map<String, dynamic> document, {returnInstanceLens: false}) {
    var il = new InstanceLens.deserialize(document, this);

    document.forEach((property, value) {
      if (value is Map) {
        il.setRelation(property, deserializeDocument(value, returnInstanceLens: true));
      }
    });

    if (returnInstanceLens) return il;
    return il.instance;
  }
}
