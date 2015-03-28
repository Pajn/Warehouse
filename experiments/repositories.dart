import 'dart:async';



// Might not be particularly useful. May be up to the companion to create a mixin?
/// Mixin to a [Repository] to add searching for entities using a companion database.
abstract class Search<T> {
  // How should [query] look and behave? May be to hard and limited to abstract by may not be very
  // useful otherwise?
  Future<List<T>> search(query);
}
