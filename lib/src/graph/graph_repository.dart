part of warehouse.graph;

/// A generic repository for working with a [GraphDbSession]
///
/// The repository needs the type(s) of the entities it will work with.
///
/// If it only will work with entities of a single type it can either be specified while
/// instantiating an repository with `var movieRepository = new GraphRepository<Movie>(session);`
/// or by inheriting the [GraphRepository] class with
/// ```dart
/// class MovieRepository extends GraphRepository<Movie> {
///    MovieRepository(GraphDbSession session) : super(session);
/// }
/// ```
///
/// If it will work with with entities of multiple types it can either be specified while
/// instantiating an repository with
/// `var movieRepository = new GraphRepository(session, types: const [Movie, Person]);`
/// or by inheriting the [GraphRepository] class with
/// ```dart
/// class MovieRepository extends GraphRepository {
///    MovieRepository(GraphDbSession session) : super(session, types: const [Movie, Person]);
/// }
/// ```
class GraphRepository<T> extends Repository<T> {
  final GraphDbSession session;
  final List<Type> _types;

  GraphRepository(GraphDbSession session, {List<Type> types}) :
    this._types = types, this.session = session, super(session) {
    if (T != dynamic && types != null) {
      throw new ArgumentError('types cant be specified if generic type T is set');
    }
  }

  List<Type> get types => (T == dynamic) ? _types : [T];

  /// Delete every entity of type [T], optionally limited using a query.
  ///
  /// This action is performed directly and is not being queued.
  /// NOTE: The deleted entities will not be detached!
  ///
  /// [types] limits to entities only of only specified types, can be [List<Type>] or [Type]
  Future deleteAll({Map where}) => session.deleteAll(where: where, types: types);

  /// Get a single entity by [id].
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<T> get(id, {depth: 1}) => session.get(id, depth: depth, types: types);

  /// Get multiple entities by id.
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<List<T>> getAll(Iterable ids, {depth: 0}) =>
    session.getAll(ids, depth: depth, types: types);

  /// Find a single entity by a query.
  ///
  /// [type] limits to entities only of that [Type]
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<T> find(Map where, {depth: 1}) => session.find(where, depth: depth, types: types);

  /// Find all entities of type [T], optionally limited using queries.
  ///
  /// [where] allows filtering on properties using [Matchers].
  /// [skip] and [limit] allows for pagination.
  /// [depth] specifies how relations should be resolved, see [resolveRelations] for a description.
  Future<List<T>> findAll({Map where, int skip: 0, int limit: 50, depth: 0, String sort, List<Type> types}) =>
    session.findAll(where: where, skip: skip, limit: limit, sort: sort, depth: depth, types: (types == null) ? this.types : types);

  Future<int> countAll({Map where, List<Type> types}) => session.countAll(where: where, types: (types == null) ? this.types : types);

  /// Fetches related nodes for [entity].
  ///
  /// [depth] specifies how relations should be resolved, valid values are:
  ///  - [int] A number that declares that all relations should be resolved to a maximum of that depth
  ///  - [String] The name of the relation that should be resolved
  ///  - [List] A list of all relations that should be resolved, can contain [String]s and [Map]s
  ///  - [Map] A map where keys are relations that should be resolved from this node and values that
  ///    are relations that should be resolved from that node. Keys can be [String]s and [List]s,
  ///    values can be [String]s, [List]s and [Map]s.
  Future<T> resolveRelations(T entity, {depth: 1}) =>
    session.resolveRelations(entity, depth: depth);
}
