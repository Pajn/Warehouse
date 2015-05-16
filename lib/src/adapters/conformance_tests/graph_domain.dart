library warehouse.adapter.conformance_tests.graph_domain;

import 'package:warehouse/graph.dart';
import 'package:warehouse/warehouse.dart';

class Movie {
  String title;
  DateTime releaseDate;
  Person director;
  List<String> genres;
  num rating;
  List<Role> cast;
}

class Person {
  String name;
}

class Actor extends Person {
  @ReverseOf(#cast)
  List<Role> roles;
}

@Edge(Movie, Actor)
class Role {
  String role;
  Movie movie;
  Actor actor;
}
