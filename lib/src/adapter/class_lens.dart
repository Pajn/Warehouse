part of warehouse.adapter;

/// A wrapper around [ClassMirror] to simply working with classes
class ClassLens {
  /// [Type] of the represented class
  final Type type;
  /// [ClassMirror] on the represented class
  final ClassMirror cm;
  /// The [LookingClass] this lens is attached to
  final LookingGlass lg;

  Map<Symbol, DeclarationMirror> _declarations;
  Map<Symbol, DeclarationMirror> _propertyFields;
  Map<Symbol, DeclarationMirror> _relationalFields;

  List get labels => findLabels(type);
  Symbol get constructor => defaultConstructor;

  /// All declarations, including inherited ones, of the represented class
  get declarations {
    _checkDeclarations();
    return _declarations;
  }

  get propertyFields {
    _checkFields();
    return _propertyFields;
  }

  get relationalFields  {
    _checkFields();
    return _relationalFields;
  }

  ClassLens(Type type, this.lg) : this.type = type, cm = reflectClass(type);

  _checkDeclarations() {
    if (_declarations == null) {
      _declarations = getDeepDeclarations(cm);
    }
  }

  _checkFields() {
    if (_propertyFields == null) {
      _propertyFields = {};
      _relationalFields = {};

      declarations.forEach((field, declaration) {
        var type = getType(declaration);
        if (type == null) return;

        if (lg.supportsTypeAsProperty(type)) {
          _propertyFields[field] = declaration;
        } else {
          _relationalFields[field] = declaration;
        }
      });
    }
  }

  InstanceLens createInstance() {
    var entity = cm.newInstance(constructor, const []);
    return new InstanceLens(this, entity.reflectee);
  }
}
