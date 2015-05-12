library warehouse.test.conformance.session;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/adapter/conformance/session_factory.dart';
import '../domain.dart';

runSessionTests(SessionFactory factory) {
  describe('DbSession', () {
    DbSession session;
    Movie avatar;

    beforeEach(() async {
      session = factory();

      avatar = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.utc(2009, 12, 18);

      session.store(avatar);
      await session.saveChanges();
    });

    describe('streams', () {
      it('should close the streams on dispose', () {
        session.onOperation.listen((_) {}, onDone: expectAsync(() {}));
        session.onCreated.listen((_) {}, onDone: expectAsync(() {}));
        session.onUpdated.listen((_) {}, onDone: expectAsync(() {}));
        session.onDeleted.listen((_) {}, onDone: expectAsync(() {}));

        session.dispose();
      });
    });

    describe('queue', () {
      it('should be possible to clear to queue', () async {
        var entity = new Movie();
        session.store(entity);
        session.clearQueue();
        await session.saveChanges();

        expect(session.entityId(entity)).toBeNull();
      });
    });

    describe('id management', () {
      it('should be possible to attach an entity manually', () async {
        var entity = new Movie();
        session.attach(entity, 'newId');

        expect(session.entityId(entity)).toEqual('newId');
      });

      it('should not be possible to attach an already attached entity', () async {
        expect(() => session.attach(avatar, 'newId')).toThrowWith(
            type: ArgumentError, message: 'The entity is already attached'
        );
      });

      it('should be possible to detach an entity manually', () async {
        session.detach(avatar);

        expect(session.entityId(avatar)).toBeNull();
      });
    });

    it('should be possible to get the db instance', () {
      expect(session.db).toBeNotNull();
    });

    it('should keep track of companion databases', () {
      expect(session.companions).toEqual({});
      session.registerCompanion(MockCompanion, mockCompanion);
      expect(session.companions.length).toEqual(1);
      expect(session.companions[MockCompanion]).toBeA(MockCompanion);
    });
  });
}
