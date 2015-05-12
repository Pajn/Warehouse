library warehouse.test.conformance.store;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/adapter/conformance/session_factory.dart';
import '../domain.dart';

runStoreTests(SessionFactory factory) {
  describe('store', () {
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

    it('should attach the entity after it is created', () async {
      var entity = new Movie();
      session.store(entity);
      await session.saveChanges();

      expect(session.entityId(entity)).toBeNotNull();
    });

    it('should fire events after an entity is created', () async {
      var entity = new Movie();
      session.store(entity);

      session.onOperation.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(entity));
        expect(operation.type).toBe(OperationType.create);
        expect(operation.entity).toBe(entity);
      }));
      session.onCreated.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(entity));
        expect(operation.type).toBe(OperationType.create);
        expect(operation.entity).toBe(entity);
      }));
      session.onUpdated.listen((_) => throw 'should not be called');
      session.onDeleted.listen((_) => throw 'should not be called');

      await session.saveChanges();
    });

    it('should be able to get an entity after it is created' , () async {
      var entity = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.utc(2009, 12, 18);

      session.store(entity);
      await session.saveChanges();
      var get = await session.get(session.entityId(entity));

      expect(get).toHaveSameProps(entity);
      expect(get).toBeA(Movie);
    });

    it('should fire events after an entity is updated', () async {
      avatar..title = 'Avatar 2';
      session.store(avatar);

      session.onOperation.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(avatar));
        expect(operation.type).toBe(OperationType.update);
        expect(operation.entity).toBe(avatar);
      }));
      session.onUpdated.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(avatar));
        expect(operation.type).toBe(OperationType.update);
        expect(operation.entity).toBe(avatar);
      }));
      session.onCreated.listen((_) => throw 'should not be called');
      session.onDeleted.listen((_) => throw 'should not be called');

      await session.saveChanges();
    });

    it('should be able to get an updated entity after it is updated' , () async {
      avatar..title = 'Avatar 2';
      session.store(avatar);
      await session.saveChanges();
      var get = await session.get(session.entityId(avatar));

      expect(get).toHaveSameProps(avatar);
      expect(get).toBeA(Movie);
    });
  });
}
