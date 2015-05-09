part of warehouse;

/// A generic repository for working with a [DbSession]
///
/// The repository needs a type of the objects it will work with. It can either be specified while
/// instantiating an object with `var movieRepository = new Repository<Movie>();` or by inheriting
/// the [Repository] class with `class MovieRepository extends Repository<Movie> {}`.
class Repository<T> {
  /// The database session this repository is connected to
  final DbSession session;

  /// Stream of entities created in this session of type [T]
  Stream<DbOperation<T>> get onCreated => session.onCreated.where((op) => op.entity is T);
  /// Stream of entities deleted in this session of type [T]
  Stream<DbOperation<T>> get onDeleted => session.onDeleted.where((op) => op.entity is T);
  /// Stream of entities updated in this session of type [T]
  Stream<DbOperation<T>> get onUpdated => session.onUpdated.where((op) => op.entity is T);

  Repository(this.session);

  /// Get a single entity by [id].
  Future<T> get(id) => session.get(id, type: T);

  /// Get multiple entities by id.
  Future<List<T>> getAll(Iterable ids) => session.getAll(ids, type: T); // Stream?

  /// Find a single entity by a query.
  Future<T> find(Map where) => session.find(where, type: T);

  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  Future<List<T>> findAll({Map where, int skip: 0, int limit: 50}) => // Stream?
    session.findAll(where: where, skip: skip, limit: limit, type: T);

  /// Count all entities of type [T], optionally limited using a query.
  Future<int> countAll({Map where}) => session.countAll(where: where, type: T);
}
