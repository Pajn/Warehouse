part of warehouse.adapter;

/// The symbol of the default (unnamed) constructor.
const defaultConstructor = const Symbol('');

/// Get the type of a declaration, or null if the declaration is not a variable or getter.
ClassMirror getType(DeclarationMirror dm) {
  if (dm is VariableMirror) {
    return dm.type;
  } else if (dm is MethodMirror && dm.isGetter) {
    return dm.returnType;
  }

  throw 'dm is neither a variable or getter';
}

/// Finds the label of a class.
///
/// A label is the name of a class.
String findLabel(object) {
  if (object == null) return null;
  if (object is Type) {
    object = reflectType(object);
  }
  if (object is! DeclarationMirror) throw 'Unsupported type ${object.runtimeType}';

  return MirrorSystem.getName(object.simpleName);
}

/// Finds all labels of a class.
///
/// A label is the name of a class, a class have multiple labels if it extends other classes.
List<String> findLabels(Type type) {
  var labels = [];
  var cm = reflectClass(type);

  do {
    var label = findLabel(cm);
    // The type of a mixin contains space in it's name, ignore those
    if (!label.contains(' ')) {
      labels.add(label);
    }

    cm = cm.superclass;
  } while(cm.superclass != null);

  return labels;
}

/// Gets the [Edge] object created by the @Edge() annotation
Edge getEdgeAnnotation(Object object) {
  var cm = reflectClass(object.runtimeType);
  return cm.metadata.singleWhere((annotation) => annotation.reflectee is Edge).reflectee;
}

bool isSubtype(object, Type superClass) {
  if (object is! ClassMirror) {
    if (object is! Type) {
      object = object.runtimeType;
    }
    object = reflectType(object);
  }
  return object.isSubtypeOf(reflectType(superClass));
}

/// Checks if [typeOrClassMirror] has an [Edge] annotation.
bool isUndirectedField(DeclarationMirror field) {
  return field.metadata.any((annotation) => annotation.reflectee is Undirected);
}

/// Checks if [typeOrClassMirror] has an [Edge] annotation.
bool isEdgeClass(typeOrClassMirror) {
  if (typeOrClassMirror is Type) typeOrClassMirror = reflectClass(typeOrClassMirror);
  return typeOrClassMirror.metadata.any((annotation) => annotation.reflectee is Edge);
}

/// Get the [ClassMirror] of the edge object, or null if there are none.
ClassMirror getEdgeType(field, ClassLens start) {
  if (field is String) {
    field = MirrorSystem.getSymbol(field);
  }

  var type = getType(start.relationalFields[field]);
  if (type.isSubtypeOf(list)) {
    type = type.typeArguments.first;
  }
  if (isEdgeClass(type)) return type;
  return null;
}

/// Find the fields that specify a relation from [from] to [to]
Iterable<DeclarationMirror> findRelationsTo(ClassLens from, ClassLens to, {allowLists: false}) =>
  from.relationalFields.values.where((declaration) {
    var type = getType(declaration);
    if (allowLists && type.isSubtypeOf(list)) {
      type = type.typeArguments.first;
    }
    return to.cm.isAssignableTo(type);
  });

/// Get the name of the relational field in the reverse direction, or null.
///
/// To be a reverse relation a field must have the same type as the start of the relation and
/// have a `@ReverseOf()` annotation with the symbol of the field in the starting class.
Symbol reverseRelationOf(Symbol name, ClassLens start, ClassLens end, [ClassLens edge]) {
  var endFields;
  if (edge != null) {
    endFields = findRelationsTo(end, edge, allowLists: true);
  }
  if (endFields == null || endFields.isEmpty) {
    endFields = findRelationsTo(end, start, allowLists: true);
  }
  if (endFields.isNotEmpty) {
    var endField = endFields.firstWhere((field) => field.metadata.any((annotation) =>
      annotation.reflectee is ReverseOf && annotation.reflectee.field == name
    ), orElse: () => null);

    if (endField != null) {
      return endField.simpleName;
    }
  }

  return null;
}

/// Get all declarations of [cm], including inherited.
Map<Symbol, DeclarationMirror> getDeepDeclarations(ClassMirror cm) {
  if (cm.superclass == null) {
    return const {};
  }

  return {}
    ..addAll(cm.declarations)
    ..addAll(getDeepDeclarations(cm.superclass));
}
