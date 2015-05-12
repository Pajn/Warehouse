library warehouse.test.conformance.get;

import 'package:guinness/guinness.dart';
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/adapter/conformance/session_factory.dart';
import '../domain.dart';

runGetTests(SessionFactory factory) {
  describe('', () {
    DbSession session;
    Movie avatar, pulpFiction;

    beforeEach(() async {
      session = factory();

      var tarantino = new Person()
        ..name = 'Quentin Tarantino';

      avatar = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.utc(2009, 12, 18);

      pulpFiction = new Movie()
        ..title = 'Pulp Fiction'
        ..releaseDate = new DateTime.utc(1994, 12, 25)
        ..director = tarantino;

      session.store(tarantino);
      session.store(avatar);
      session.store(pulpFiction);

      await session.saveChanges();
    });

    describe('get', () {
      it('should be able to get an entity by id', () async {
        var entity = await session.get(session.entityId(avatar));

        expect(entity).toHaveSameProps(avatar);
      });

      it('should get directly connected entities', () async {
        // Depending on the database model this may be a relation, join or embedded.
        // All models should default to include at least the directly connected entities when
        // getting a single entity. How deeper connections are handled depends on the model.

        var entity = await session.get(session.entityId(pulpFiction));

        expect(entity.title).toEqual('Pulp Fiction');
        expect(entity.releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
        expect(entity.director).toBeA(Person);
        expect(entity.director.name).toEqual('Quentin Tarantino');
      });
    });

    describe('getAll', () {
      it('should be able to get multiple entities by id', () async {
        var entities = await session.getAll([session.entityId(avatar), session.entityId(pulpFiction)]);

        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1].title).toEqual('Pulp Fiction');
        expect(entities[1].releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
      });
    });
  });
}
