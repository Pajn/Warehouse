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
  DeclarationMirror _idField;

  List get labels => findLabels(type);
  Symbol get constructor => defaultConstructor;

  /// All declarations, including inherited ones, of the represented class
  Map<Symbol, DeclarationMirror> get declarations {
    _checkDeclarations();
    return _declarations;
  }

  Map<Symbol, DeclarationMirror> get propertyFields {
    _checkFields();
    return _propertyFields;
  }

  Map<Symbol, DeclarationMirror> get relationalFields  {
    _checkFields();
    return _relationalFields;
  }

  DeclarationMirror get idField  {
    _checkDeclarations();
    return _idField;
  }

  ClassLens(Type type, this.lg) : this.type = type, cm = reflectClass(type);

  _checkDeclarations() {
    if (_declarations == null) {
      _declarations = {};
      getDeepDeclarations(cm).forEach((name, declaration) {
        final isIgnored = declaration.metadata
            .any((annotation) => annotation.reflectee is Ignore);

        if (!isIgnored && !declaration.isPrivate && (
              declaration is VariableMirror ||
              (declaration is MethodMirror && declaration.isGetter)
            ) &&
            !declaration.isStatic) {
          if (declaration.simpleName == #id) {
            _idField = declaration;
          } else {
            _declarations[name] = declaration;
          }
        }
      });
    }
  }

  _checkFields() {
    if (_propertyFields == null) {
      _propertyFields = {};
      _relationalFields = {};

      declarations.forEach((field, declaration) {
        var cm = getType(declaration);
        if (cm == null) return;

        if (lg.supportsTypeAsProperty(cm)) {
          if (lg.supportLists || !getType(declaration).isSubtypeOf(list)) {
            _propertyFields[field] = declaration;
          }
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
