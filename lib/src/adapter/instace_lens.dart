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
          value = converter.toDatabase(value);
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
      var converter = cl.lg.converterFor(getType(cl.propertyFields[field]));
      if (converter != null) {
        value = converter.fromDatabase(value);
      }
    }

    im.setField(field, value);
  }

  void setRelation(field, InstanceLens end, [InstanceLens edge]) {
    if (field is String) {
      if (field.startsWith('@')) return;
      field = MirrorSystem.getSymbol(field);
    }

    if (edge == null) {
      im.setField(field, end.instance);

      var endName = reverseRelationOf(field, cl, end.cl);
      if (endName != null) {
        end.im.setField(endName, instance);
      }
    } else {
      im.setField(field, edge.instance);

      var startReferences = findRelationsTo(edge.cl, cl);
      if (startReferences.isNotEmpty) {
        if (startReferences.length > 1) throw 'An Edge can only have one reference to its start node';
        var referenceName = startReferences[0].simpleName;

        if (referenceName != null) {
          edge.im.setField(referenceName, instance);
        }
      }

      var endReferences = findRelationsTo(edge.cl, end.cl);
      if (endReferences.isNotEmpty) {
        if (endReferences.length > 1) throw 'An Edge can only have one reference to its end node';
        var referenceName = endReferences[0].simpleName;

        if (referenceName != null) {
          edge.im.setField(referenceName, end.instance);
        }
      }

      var endName = reverseRelationOf(field, cl, end.cl);
      if (endName != null) {
        end.im.setField(endName, edge.instance);
      }
    }
  }

  Map<String, dynamic> serialize() =>
    properties
      ..['@type'] = typeConverter.toDatabase(instance.runtimeType);
}
