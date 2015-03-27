# Multi-Model thoughts
Different database models have different needs and behaviours that needs to be solved in a
multi-model object mapper.

## Graph
### Neo4j
- No set schema
- Only "simple" values on nodes and relations (int, decimal, bool, String and lists of those)
- Only nodes can have relations

### OrientDB
- Optional class-based schema with inheritance
- Supports nested objects
- Many types (int, decimal, bool, String, Datetime, Binary, map, list, link, Decimal, dynamic)

## Document
### MongoDB
- No set schema
- Supports nested objects

## SQL
- All entities must look the same. (How should polymorphism be solved?)
- Needs migrations (Can existing libraries like [dartabase_migration](https://pub.dartlang.org/packages/dartabase_migration) be used?)

## Key Value
Use cases? Can [cargo](https://pub.dartlang.org/packages/cargo) be leveraged?

## Companion
Usually not used as primary database but instead added as a companion to provide additional benefits

### Elasticsearch
Document database, used for searching
- set but automatically implied schema, some stuff like geo-point need to be mapped beforehand
- indexes and documents in them may not map to the usually entity classes, depends on how and what the user want to search.
