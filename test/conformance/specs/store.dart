library warehouse.test.conformance.store;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/warehouse.dart';
import '../domain.dart';

runStoreTests(DbSession session) {
  describe('store', () {
    Movie avatar;

    beforeEach(() async {
      avatar = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.now();
      await session.store(avatar);
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
        expect(operation.operation).toBe(OperationType.create);
        expect(operation.entity).toBe(entity);
      }));
      session.onCreated.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(entity));
        expect(operation.operation).toBe(OperationType.create);
        expect(operation.entity).toBe(entity);
      }));

      await session.saveChanges();
    });

    it('should be able to get an entity after it is created' , () async {
      var entity = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.now();

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
        expect(operation.operation).toBe(OperationType.update);
        expect(operation.entity).toBe(avatar);
      }));
      session.onUpdated.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(avatar));
        expect(operation.operation).toBe(OperationType.update);
        expect(operation.entity).toBe(avatar);
      }));

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
