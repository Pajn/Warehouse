library warehouse.test.conformance.delete;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';
import '../domain.dart';

runDeleteTests(SessionFactory sessionFactory, RepositoryFactory repositoryFactory) {
  describe('', () {
    DbSession session;
    Repository movieRepository, personRepository;
    Movie avatar;
    Person tarantino;

    beforeEach(() async {
      session = sessionFactory();
      movieRepository = repositoryFactory(session, Movie);
      personRepository = repositoryFactory(session, Person);

      tarantino = new Person()
        ..name = 'Quentin Tarantino';

      avatar = new Movie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.utc(2009, 12, 18);

      session.store(tarantino);
      session.store(avatar);

      await session.saveChanges();
    });

    describe('delete', () {

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
          expect(operation.type).toBe(OperationType.delete);
          expect(operation.entity).toBe(avatar);
        }));
        session.onDeleted.listen(expectAsync((operation) {
          expect(operation.id).toEqual(id);
          expect(operation.type).toBe(OperationType.delete);
          expect(operation.entity).toBe(avatar);
        }));
        session.onCreated.listen((_) => throw 'should not be called');
        session.onUpdated.listen((_) => throw 'should not be called');

        await session.saveChanges();
      });

      it('should not be able to get an entity after its deleted' , () async {
        var id = session.entityId(avatar);
        session.delete(avatar);
        await session.saveChanges();
        var get = await movieRepository.get(id);

        expect(get).toBeNull();
      });

      it('should only delete the requested entity', () async {
        session.delete(avatar);
        await session.saveChanges();

        expect(session.entityId(tarantino)).toBeNotNull();

        var get = await personRepository.get(session.entityId(tarantino));

        expect(get).toHaveSameProps(tarantino);
      });

      it('should throw on unknown entity', () async {
        expect(() => session.delete(new Movie())).toThrowWith(
          type: ArgumentError,
          message: 'The entity is not known by the session'
        );
      });
    });

    describe('deleteAll', () {

      it('should not be able to get entities after they are deleted' , () async {
        var id = session.entityId(avatar);
        await movieRepository.deleteAll();
        var get = await movieRepository.get(id);

        expect(get).toBeNull();
      });

      it('should be able to only delete entities with a specific type' , () async {
        var avatarId = session.entityId(avatar);
        var tarantinoId = session.entityId(tarantino);

        await movieRepository.deleteAll();

        var movie = await movieRepository.get(avatarId);
        var person = await personRepository.get(tarantinoId);

        expect(movie).toBeNull();
        expect(person).toHaveSameProps(tarantino);
      });
    });
  });
}
