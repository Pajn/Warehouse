library warehouse.test.conformance.delete;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/warehouse.dart';
import '../domain.dart';

runDeleteTests(DbSession session) {
  describe('delete', () {
    Movie avatar;

    beforeEach(() async {
      avatar = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.now();
      await session.store(avatar);
    });

    it('should dettach the entity after it is deleted', () async {
      session.delete(avatar);
      await session.saveChanges();

      expect(session.entityId(avatar)).toBeNull();
    });

    it('should fire events after an entity is deleted', () async {
      var id = session.entityId(avatar);
      session.delete(avatar);

      session.onOperation.listen(expectAsync((operation) {
        expect(operation.id).toEqual(id);
        expect(operation.operation).toBe(OperationType.delete);
        expect(operation.entity).toBe(avatar);
      }));
      session.onDeleted.listen(expectAsync((operation) {
        expect(operation.id).toEqual(id);
        expect(operation.operation).toBe(OperationType.delete);
        expect(operation.entity).toBe(avatar);
      }));

      await session.saveChanges();
    });

    it('should not be able to get an entity after its deleted' , () async {
      var id = session.entityId(avatar);
      session.delete(avatar);
      await session.saveChanges();
      var get = await session.get(id);

      expect(get).toBeNull();
    });
  });
}
