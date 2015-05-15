part of warehouse.graph;

/// Matchers to specify in where queries.
///
/// Used though constants [IS] or [DO]
class GraphMatcher extends NormalMatcher {
  @override
  GraphNotMatcher get not => new GraphNotMatcher();

  const GraphMatcher();
}

class GraphNotMatcher extends NotMatcher {
  GraphNotMatcher([Matcher invertedMatcher]) : super(invertedMatcher);
}

const DO = const GraphMatcher();
const IS = const GraphMatcher();
