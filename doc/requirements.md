# Requirements
Trying to define what should be handled and how...

## Entities
Entities should be PODO (plain old dart objects). Although sometimes entities needs to be
differentiated (I.E. relation objects rather than nodes in graphs), prefer annotations in such case.
Sometimes some properties may be required, then a class that may be extended, mixed in or
implemented should be okay it they provide no bloat.

## Polymorphism
The user should get objects of the same type that were passed in, entities should be able to inherit
each other. Should be able to query on different levels in the inheritance chain. I.E. should be
able to find all persons or all actors.

## Multi-Model
Multiple models should behave correctly and may diverge if needed to create a good experience. Basic
operations (store, delete, findAll, get...) should work with no modifications.

## Companion databases
Companion databases should be supported. Current focus is elasticsearch.

## Validation
Validation may be business specific, user should be able to plug-in there solution. Maybe provide
a good default ([constrain](https://pub.dartlang.org/packages/constrain)?).
Should Repository.store throw on validation error? Exception may contain
`Set<ConstraintViolation> violations` if constrain is used.
Validation as mixin or constructor parameter? - User should not need to extend DbSession so
constructor parameter may be required.

## Abstraction
Models and databases have differences that should be abstracted away to create an cohesive experience.
Databases in the same model should be easily exchangeable if no custom database features are used.
 
### Types
Different databases supports different types, a standard set of types that works all over needs to
be defined. (Should additional types specific to some databases be supported?)
- int
- double
- bool
- String
- DateTime (can be serialized as timestamp when not supported, may limit _queryability_ though)
- GeoPoint? (Supported only by some, should be easy to serialize but hard to query)  

### Relations
References to other objects should be handled depending on the model.
Relations for graphs, sub-documents for documents, FK for SQL.
Can sub-documents support many-to-many? What about querying data that is nested?

### Queries
Queries are hard, to should always be easy to bail out and use raw database queries.
Start with only simple queries.
