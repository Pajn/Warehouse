import 'dart:async';

/// Holds state of the session like the queue of entities to create, update or delete.
abstract class DbSession {
  /// Get the database id of [entity]
  dynamic entityId(entity);
  /// Marks [entity] for deletion.
  void delete(entity);
  /// Marks [entity] for creation or update.
  void store(entity);
  /// Persist the queue of changes to the database
  Future saveChanges();
}

abstract class Repository<T> {
  /// Get a single entity by [id].
  Future<T> get(id);
  /// Get multiple entities by id.
  Future<List<T>> getAll(List ids); // Stream?

  /// Find a single entity by a query.
  Future<T> find(where);
  /// FindAll entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  Future<List<T>> findAll({Map where, int skip, int limit}); // Stream?
}

/// Mixin to a [Repository] to add searching for entities using a companion database.
abstract class Search<T> {
  // Lets the user prepare the data for searching
  Map asSearchable(T entity);
  // How should [query] look and behave? May be to hard and limited to abstract by may not be very
  // useful otherwise?
  List<T> search(query);
}
