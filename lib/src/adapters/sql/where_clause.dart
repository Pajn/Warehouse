library neo4j_dart.warehouse.where_clause;

import 'package:warehouse/adapters/base.dart';
import 'package:warehouse/sql.dart';

void setParameter(List parameters, value, LookingGlass lg) {
  var converter = lg.convertedTypes[value.runtimeType];
  if (converter != null) {
    value = converter.toDatabase(value);
  }

  parameters.add(value);
}

String buildWhereClause(
    Map where, List parameters, String prefix, SqlEndpoint db) {
  var escapeChar = db.escapeChar;
  var whereClause;

  if (where != null && where.isNotEmpty) {
    var filters = [];

    where.forEach((property, value) {
      if (prefix != null) {
        property = '$escapeChar$prefix$escapeChar.$escapeChar$property$escapeChar';
      } else {
        property = '$escapeChar$property$escapeChar';
      }

      if (value is Matcher) {
        filters.add(visitMatcher(value, parameters, db).replaceAll(
            '{field}', '$property'));
      } else {
        setParameter(parameters, value, db.lg);
        filters.add('$property = ?');
      }
    });

    whereClause = filters.join(' AND ');
  }

  return (whereClause == null) ? '' : whereClause;
}

String visitMatcher(Matcher matcher, List parameters, SqlEndpoint db) {
  if (db.matchers.containsKey(matcher.runtimeType)) {
    return db.matchers[matcher.runtimeType](matcher, parameters, db.lg);
  } else if (matcher is ExistMatcher) {
    return '{field} IS NOT NULL';
  } else if (matcher is NotMatcher) {
    if (matcher.invertedMatcher is EqualsMatcher) {
      setParameter(parameters, matcher.invertedMatcher.expected, db.lg);
      return '{field} <> ?';
    } else {
      return 'NOT(${visitMatcher(matcher.invertedMatcher, parameters, db)})';
    }
  } else if (matcher is StringContainMatcher) {
    setParameter(parameters, '%${matcher.expected}%', db.lg);
    return "{field} LIKE ?";
  } else if (matcher is InListMatcher) {
    var sb = new StringBuffer('{field} IN (');
    var first = true;
    for (var value in matcher.list) {
      if (first) {
        first = false;
      } else {
        sb.write(',');
      }
      setParameter(parameters, value, db.lg);
      sb.write('?');
    }
    sb.write(')');
    return sb.toString();
  } else if (matcher is EqualsMatcher) {
    setParameter(parameters, matcher.expected, db.lg);
    return '{field} = ?';
  } else if (matcher is LessThanMatcher) {
    setParameter(parameters, matcher.expected, db.lg);
    return '{field} < ?';
  } else if (matcher is LessThanOrEqualToMatcher) {
    setParameter(parameters, matcher.expected, db.lg);
    return '{field} <= ?';
  } else if (matcher is GreaterThanMatcher) {
    setParameter(parameters, matcher.expected, db.lg);
    return '{field} > ?';
  } else if (matcher is GreaterThanOrEqualToMatcher) {
    setParameter(parameters, matcher.expected, db.lg);
    return '{field} >= ?';
  } else if (matcher is InRangeMatcher) {
    setParameter(parameters, matcher.min, db.lg);
    setParameter(parameters, matcher.max, db.lg);
    return '{field} BETWEEN ? AND ?';
  } else if (matcher is RegexpMatcher) {
    setParameter(parameters, matcher.regexp, db.lg);
    return '{field} REGEXP ?';
  } else {
    throw 'Unsuported matcher ${matcher.runtimeType}';
  }
}
