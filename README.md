# Warehouse
[![Build Status](https://travis-ci.org/Pajn/Warehouse.svg?branch=master)](https://travis-ci.org/Pajn/Warehouse)

An experiment creating a multi-model database to object mapper for Dart.
The current focus is graph databases with an Elasticsearch companion, but
document databases are a big interest too.

## Features
- PODO (Plain Old Dart Objects)
- Polymorphism (you get an instance of the same class that you saved it with)
- Clear interfaces for interchangeability
- Minimum support for bool, num, String, DateTime, GeoPoint, Type as property types.
  Can be further extended by the database adapter.

### Graph Specific
- Edge objects
- Undirected edges

The interface is built in layers, the top level beeing [DbSession][] and
[Repository][]. Under are model-specific versions like [GraphDbSession][] and
[GraphRepository][]. Code that only depends on [DbSession][] should be usable
with all database adapters, code that depends only on [GraphDbSession][] should
be usable with all graph database adapters. There are a rich test suite that
verifies that adapters conform to the specified interface.

## Usage
Se the [example folder][] for a descriptive and simple example.
The [conformance tests][] for a collection of small, isolated examples.
Look up the [api documentation][] for detailed descriptions. 

## Adapters
Currently there is only a graph database [Neo4j adapter][], an
[ElasticSearch companion adapter][] and a provided mock adapter for use in tests.

## Inspirations
- RavenDB
- Entity Framework
- Spring Data

Licenced under Apache 2.
Please file use cases, thoughts, ideas or issues at the [issue tracker][tracker].

[tracker]: https://github.com/Pajn/Warehouse/issues
[DbSession]: https://github.com/Pajn/Warehouse/blob/master/lib/src/db_session.dart
[Repository]: https://github.com/Pajn/Warehouse/blob/master/lib/src/repository.dart
[GraphDbSession]: https://github.com/Pajn/Warehouse/blob/master/lib/src/graph/graph_db_session.dart
[GraphRepository]: https://github.com/Pajn/Warehouse/blob/master/lib/src/graph/graph_repository.dart
[example folder]: https://github.com/Pajn/Warehouse/tree/master/example
[conformance tests]: https://github.com/Pajn/Warehouse/tree/master/lib/src/adapters/conformance_tests
[api documentation]: http://www.dartdocs.org/documentation/warehouse/latest
[Neo4j adapter]: https://pub.dartlang.org/packages/neo4j_dart
[ElasticSearch companion adapter]: https://pub.dartlang.org/packages/elastic_dart
