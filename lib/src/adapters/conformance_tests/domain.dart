library warehouse.adapter.conformance_tests.domain;

import 'package:constrain/constrain.dart';
import 'package:warehouse/warehouse.dart';

//enum AnimationTechnique {
//  traditional, stopMotion, computer,
//}

class AnimationTechnique {
  static const traditional = 1;
  static const stopMotion = 2;
  static const computer = 3;
}

class Movie {
  @NotNull()
  String title;
  DateTime releaseDate;
  Person director;
  String genre;
  List<String> genres;
  num rating;
  List<Person> cast;
  @Ignore()
  int ageRating;
}

class AnimatedMovie extends Movie {
  int animationTechnique;
}

class Person {
  var id;
  String name;
}

class DefaultValue {
  String defaultValue = 'default';
}

class Mixin {
  String mixinValue;
}

class Base {
  GeoPoint baseValue;
}

class Child extends Base with Mixin {}

class PrivateValue {
  var _private;
  String get private => _private;
  set private(String private) => _private = private;
}

class OnlyGetter {
  final String finalField = 'final';
  String get getter => 'getter';
}

class MockCompanion {}
mockCompanion(DbSession) => new MockCompanion();
