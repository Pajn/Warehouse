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

export 'package:warehouse/warehouse.dart';

part '../src/adapter/class_lens.dart';
part '../src/adapter/converters.dart';
part '../src/adapter/db_session.dart';
part '../src/adapter/instace_lens.dart';
part '../src/adapter/looking_glass.dart';
part '../src/adapter/mirrors.dart';
part '../src/adapter/validation.dart';
