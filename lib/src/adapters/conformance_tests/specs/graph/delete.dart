library warehouse.test.conformance.graph.delete;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/graph.dart';
import 'package:warehouse/src/adapters/conformance_tests/graph_domain.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';

runGraphDeleteTests(SessionFactory factory) {
  describe('delete', () {
    GraphDbSession session;
    Person freeman, mcKellen;
    Role bilbo, gandalf;
    Movie theHobbit;

    beforeEach(() async {
      session = factory();

      freeman = new Actor()..name = 'Martin Freeman';
      mcKellen = new Actor()..name = 'Ian McKellen';

      bilbo = new Role()..role = 'Bilbo' ..actor = freeman;
      gandalf = new Role()..role = 'Gandalf' ..actor = mcKellen;

      theHobbit = new Movie()
        ..title = 'The Hobbit: An Unexpected Journey'
        ..releaseDate = new DateTime.utc(2012, 12, 12)
        ..genres = ['adventure']
        ..rating = 8.0
        ..cast = [bilbo, gandalf];

      session.store(freeman);
      session.store(mcKellen);
      session.store(theHobbit);
      await session.saveChanges();
    });

    it('should not delete nodes with relations', () {
      var id = session.entityId(theHobbit);
      session.delete(theHobbit);

      return session.saveChanges()
        .then((_) => throw 'should have thrown')
        .catchError(expectAsync((e) async {
          expect(e).toBeA(StateError);
          expect(e.message).toContain('still have relations');

          var get = await session.get(id);
          expect(get.title).toEqual('The Hobbit: An Unexpected Journey');
          expect(get.cast.length).toEqual(2);
        }));
    });

    it('should be able to forcefully delete nodes with relations', () async {
      var id = session.entityId(theHobbit);
      session.delete(theHobbit, deleteEdges: true);
      await session.saveChanges();

      var get = await session.get(id);

      expect(get).toBeNull();
    });
  });
}
