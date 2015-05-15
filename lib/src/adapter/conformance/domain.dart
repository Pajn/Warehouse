library warehouse.adapter.conformance_tests.domain;

//enum AnimationTechnique {
//  traditional, stopMotion, computer,
//}

class AnimationTechnique {
  static const traditional = 1;
  static const stopMotion = 2;
  static const computer = 3;
}

class Movie {
  String title;
  DateTime releaseDate;
  Person director;
  String genre;
  num rating;
}

class AnimatedMovie extends Movie {
  int animationTechnique;
}

class Person {
  String name;
}

class MockCompanion {}
mockCompanion(DbSession) => new MockCompanion();
