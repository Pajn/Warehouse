/// Contains classes and helpers for developing a connector.
///
/// This should not be needed to import if you are only connecting to a database using an
/// existing connector.
///
/// Connector developers should inherit and implement abstract methods in [DbSessionBase].
library warehouse.connector;

import 'dart:async';
import 'dart:collection';

import 'package:warehouse/warehouse.dart';
export 'package:warehouse/warehouse.dart';

part 'src/connector/db_session.dart';
