/// Example on how to use Warehouse for storing and querying, here
/// mock implementations is used but they should be interchangeable to any
/// adapter.
library warehouse.example.domain;

import 'package:warehouse/mocks.dart';
import 'package:warehouse/warehouse.dart';
import 'entities.dart';

main() async {
  /// Instantiate a DbSession.
  var session = new MockSession();
  /// Instantiate your repositories
  var movieRepository = new MockRepository<Movie>(session);

  /// Store entities to create them
  session.store(
      new AnimatedMovie()
        ..title = 'The Hobbit: An Unexpected Journey'
        ..releaseDate = new DateTime.utc(2012, 12, 12)
        ..genres = ['adventure']
        ..rating = 8.0
        ..animationTechnique = AnimationTechnique.computer
  );

  /// store and delete only queues the changes, persist them with saveChanges
  await session.saveChanges();

  /// Query data using the repository
  var theHobbit = await movieRepository.find({'title': DO.match('The Hobbit')});

  /// Update entities by modifying and then storing them
  theHobbit.rating = 8.1;
  session.store(theHobbit);
  await session.saveChanges();

  /// Delete entities using delete
  session.delete(theHobbit);
  await session.saveChanges();
}
