/// Examples on how entity classes may look with Warehouse
library warehouse.example.domain;

import 'package:constrain/constrain.dart';

class Movie {
  /// Built in support for validation using the constrain library
  @NotNull()
  String title;
  num rating;
  /// Support for DateTime values
  DateTime releaseDate;
  /// Support for lists if the underlying database supports it
  List<String> genres;

  /// Support for relations
  Person director;
  List<Person> cast;
}

/// Support for extending or mixin in other classes
class AnimatedMovie extends Movie {
  int animationTechnique;
}

class Person {
  /// If there exists a parameter named id it will be filled by the database id
  var id;
  String name;
}

class AnimationTechnique {
  static const traditional = 1;
  static const stopMotion = 2;
  static const computer = 3;
}
