library warehouse.adapter.conformance_tests.session_factory;

import 'package:warehouse/warehouse.dart';

typedef DbSession SessionFactory();
typedef GraphDbSession GraphSessionFactory();
typedef Repository RepositoryFactory(DbSession session, Type type);
