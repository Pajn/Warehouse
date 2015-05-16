part of warehouse;

/// A generic repository for working with a [DbSession]
///
/// The repository needs a type of the entities it will work with. It can either be specified while
/// instantiating a repository with `var movieRepository = new Repository<Movie>();` or
/// by inheriting the [Repository] class with `class MovieRepository extends Repository<Movie> {}`.
/// This repository is abstract, depending on the database model it is provided by the adapter or
/// as a domain specific version.
abstract class Repository<T> {
  /// The database session this repository is connected to
  final DbSession session;

  /// Stream of entities created in this session of type [T]
  Stream<DbOperation<T>> get onCreated => session.onCreated.where((op) => op.entity is T);
  /// Stream of entities deleted in this session of type [T]
  Stream<DbOperation<T>> get onDeleted => session.onDeleted.where((op) => op.entity is T);
  /// Stream of entities updated in this session of type [T]
  Stream<DbOperation<T>> get onUpdated => session.onUpdated.where((op) => op.entity is T);

  Repository(this.session);

  /// Delete every entity of type [T], optionally limited using a query.
  ///
  /// This action is performed directly and is not being queued.
  /// NOTE: The deleted entities will not be detached!
  Future deleteAll({Map where});

  /// Get a single entity by [id].
  Future<T> get(id);

  /// Get multiple entities by id.
  Future<List<T>> getAll(Iterable ids);

  /// Find a single entity by a query.
  Future<T> find(Map where);

  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [sort] property to sort on
  /// [types] a list of types to filter on
  Future<List<T>> findAll({Map where, int skip: 0, int limit: 50, String sort, List<Type> types});

  /// Count all entities of type [T], optionally limited using a query.
  Future<int> countAll({Map where, List<Type> types});
}
