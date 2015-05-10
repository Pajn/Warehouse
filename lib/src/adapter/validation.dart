part of warehouse.adapter;

typedef Validator(entity, bool isNew);

Validator defaultValidator = constrainValidator;

class ValidationError extends FormatException {
  const ValidationError([message]) : super(message);
}

class ConstrainValidationError extends ValidationError {
  final Set<constrain.ConstraintViolation> violations;
  ConstrainValidationError(this.violations) :
    super('The entity could not be validated, see violations field');
}

constrain.Validator _v = new constrain.Validator();

constrainValidator(entity, bool isNew) async {
  var violations = _v.validate(entity);
  if (violations.isNotEmpty) {
    throw new ConstrainValidationError(violations);
  }
}
