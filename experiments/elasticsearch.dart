/// Experiment on how attaching Elasticsearch as a companion could work

class Movie {
  String title;
  Person director;
  List<Person> actors;
  // ...
}
class Person {
  String name;
  // ...
}

main() {
  var session = new DbSession();
  var es = new Elasticsearch();

  // Specify that movies should be indexed and include the director and actors names.

  // Idea 1, provide a function that prepares the entity. Should provide most flexibility
  session.addCompanion(es.createCompanion({
    Movie: (movie) => {
      'title': movie.title,
      'director': movie.director.name,
      'actors': movie.actors.map((actor) => actor.name),
    }
  }));

  // Idea 2, specify properties to include, be clever on relations
  session.addCompanion(es.createCompanion({
    Movie: [
      'title'
      'director.name', // Should the field in ES be named director, director_name or something else?
      'actors.name',
    ]
  }));
}

class MovieRepository extends Repository<Movie> with Elasticsearch<Movie> {
  MovieRepository(DbSession session) : super(session);

  // A raw elasticsearch query is specified by the repository, this gives a lot of power and freedom
  // but locks the repo to a specific backend. Should this be abstracted, how?
  //
  // Elasticsearch only holds part of the data, should results be looked up against the main-data store?
  search(String query) =>
    super.search({
      'multi_match': {
        'query': query,
        'type': 'best_fields',
        'fields': [ 'title^2', 'director', 'actors' ],
      }
    });
}
