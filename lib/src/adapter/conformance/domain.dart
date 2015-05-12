library warehouse.adapter.conformance_tests.domain;

class Movie {
  String title;
  DateTime releaseDate;
  Person director;
  String genre;
  num rating;
}

class Person {
  String name;
}

class MockCompanion {}
mockCompanion(DbSession) => new MockCompanion();
