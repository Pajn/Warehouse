part of warehouse.adapter;

/// A wrapper around [InstanceMirror] to simply working with instances
class InstanceLens {
  final ClassLens cl;
  final InstanceMirror im;
  final instance;

  Map<String, dynamic> get properties {
    var properties = {};
    for (var dm in cl.propertyFields.values) {
      var name = MirrorSystem.getName(dm.simpleName);
      var value = im.getField(dm.simpleName).reflectee;

      if (value != null) {
        var converter = cl.lg.converterFor(getType(dm));
        if (converter != null) {
          if (value is List && cl.lg.supportLists) {
            value = value.map(converter.toDatabase);
          } else {
            value = converter.toDatabase(value);
          }
        }
      }

      properties[name] = value;
    }
    return properties;
  }

  Map<String, dynamic> get relations {
    var relations = {};
    for (var dm in cl.relationalFields.values) {
      var name = MirrorSystem.getName(dm.simpleName);
      relations[name] = im.getField(dm.simpleName).reflectee;
    }
    return relations;
  }

  InstanceLens(this.cl, instance) :
      im = reflect(instance),
      this.instance = instance;

  factory InstanceLens.fromObject(Object object, LookingGlass lg) {
    var cl = new ClassLens(object.runtimeType, lg);
    return new InstanceLens(cl, object);
  }

  factory InstanceLens.deserialize(Map entity, LookingGlass lg) {
    var type = typeConverter.fromDatabase(entity['@type']);
    var cl = lg.lookOnClass(type);
    var il = cl.createInstance();

    entity.forEach((property, value) {
      if (value is! Map) {
        il.setProperty(property, value);
      }
    });

    return il;
  }

  void setProperty(field, value) {
    if (field is String) {
      if (field.startsWith('@')) return;
      field = MirrorSystem.getSymbol(field);
    }

    if (value != null) {
      var dm = cl.propertyFields[field];
      if (dm == null) return;
      var isList = false;
      var type = getType(dm);
      if (type.isSubtypeOf(list)) {
        isList = true;
        type = type.typeArguments.first;
      }
      var converter = cl.lg.converterFor(type);
      if (converter != null) {
        if (isList) {
          value = value.map(converter.fromDatabase).toList();
        } else {
          value = converter.fromDatabase(value);
        }
      }
    }

    try {
      im.setField(field, value);
    } on NoSuchMethodError catch (_) {
      // The field does not exist, may be ok. Should at least not crash
      // TODO: log?
    }
  }

  void setRelation(field, InstanceLens end, [ClassMirror edgeType, Map edgeProperties]) {
    if (field is String) {
      if (field.startsWith('@')) return;
      field = MirrorSystem.getSymbol(field);
    }

    if (edgeType == null) {
      setRelationalField(field, end.instance);

      var endName = reverseRelationOf(field, cl, end.cl);
      if (endName != null) {
        end.setRelationalField(endName, instance);
      } else if (isUndirectedField(cl.relationalFields[field])) {
        end.setRelationalField(field, instance);
      }
    } else {
      var edge = new ClassLens(edgeType.reflectedType, cl.lg).createInstance();
      edgeProperties.forEach(edge.setProperty);

      setRelationalField(field, edge.instance);

      var isUndirected = isUndirectedField(cl.relationalFields[field]);

      var tailReferences = findRelationsTo(edge.cl, cl, allowLists: isUndirected);
      if (tailReferences.isNotEmpty) {
        if (tailReferences.length > 1) throw 'An Edge can only have one reference to its tail/start node';
        var referenceName = tailReferences.first.simpleName;

        if (referenceName != null) {
          edge.setRelationalField(referenceName, instance);
        }
      }

      var headReferences = findRelationsTo(edge.cl, end.cl, allowLists: isUndirected);
      if (headReferences.isNotEmpty) {
        if (headReferences.length > 1) throw 'An Edge can only have one reference to its head/end node';
        var referenceName = headReferences.first.simpleName;

        if (referenceName != null) {
          edge.setRelationalField(referenceName, end.instance);
        }
      }

      var headName = reverseRelationOf(field, cl, end.cl, edge.cl);
      if (headName != null) {
        end.setRelationalField(headName, edge.instance);
      } else if (isUndirected) {
        end.setRelationalField(field, edge.instance);
      }
    }
  }

  void setRelationalField(Symbol field, value) {
    if (getType(cl.relationalFields[field]).isSubtypeOf(list)) {
      var oldValue = im.getField(field).reflectee;
      if (oldValue == null) {
        value = [value];
      } else {
        value = new List.from(oldValue)..add(value);
      }
    }

    try {
      im.setField(field, value);
    } on NoSuchMethodError catch (_) {
      // The field does not exist, may be ok. Should at least not crash
      // TODO: log?
    }
  }

  /// True if [field] declares an undirected edge
  bool isUndirected(String field) {
    var symbol = MirrorSystem.getSymbol(field);

    return cl.relationalFields.containsKey(symbol) &&
           isUndirectedField(cl.relationalFields[symbol]);
  }

  Map<String, dynamic> serialize() =>
    properties
      ..['@type'] = typeConverter.toDatabase(instance.runtimeType);
}
