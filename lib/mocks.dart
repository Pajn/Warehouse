/// Mock implementations of [DbSession] and [Repository] for tests.
///
/// An implementation using an in-memory [Map], useful in tests.
library warehouse.mocks;

import 'dart:async';
import 'package:warehouse/adapters/base.dart';
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/mocks/mock_matchers.dart';

part 'src/mocks/mock_repository.dart';
part 'src/mocks/mock_session.dart';
