/// Contains classes and helpers for developing an adapter.
///
/// This should not be needed to import if you are only connecting to a database using an
/// existing adapter.
///
/// Adapter developers should inherit and implement abstract methods in [DbSessionBase].
library warehouse.adapter;

import 'dart:async';
import 'dart:collection';
import 'dart:mirrors';
import 'package:constrain/constrain.dart' as constrain;

import 'package:warehouse/graph.dart';
import 'package:warehouse/warehouse.dart';

part '../src/adapters/class_lens.dart';
part '../src/adapters/converters.dart';
part '../src/adapters/db_session.dart';
part '../src/adapters/graph/edge_info.dart';
part '../src/adapters/instace_lens.dart';
part '../src/adapters/looking_glass.dart';
part '../src/adapters/mirrors.dart';
part '../src/adapters/repository.dart';
part '../src/adapters/validation.dart';
