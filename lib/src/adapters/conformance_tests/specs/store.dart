library warehouse.test.conformance.store;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/adapters/base.dart';
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';
import '../domain.dart';

runStoreTests(SessionFactory sessionFactory, RepositoryFactory repositoryFactory) {
  describe('store', () {
    DbSession session;
    Repository repository;
    Person abbington, armitage, freeman, mcKellen, tarantino;
    Movie avatar, killBill, killBill2, pulpFiction, theHobbit;

    beforeEach(() async {
      session = sessionFactory();
      repository = repositoryFactory(session, Movie);

      abbington = new Person()..name = 'Amanda Abbington';
      armitage = new Person()..name = 'Richard Armitage';
      freeman = new Person()..name = 'Martin Freeman';
      mcKellen = new Person()..name = 'Ian McKellen';
      tarantino = new Person()..name = 'Quentin Tarantino';

      avatar = new AnimatedMovie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.utc(2009, 12, 18);

      killBill = new Movie()
        ..title = 'Kill Bill - Vol. 1'
        ..releaseDate = new DateTime.utc(2003, 12, 3)
        ..director = tarantino
        ..genre = 'action'
        ..rating = 8.1;

      killBill2 = new Movie()
        ..title = 'Kill Bill - Vol. 2'
        ..releaseDate = new DateTime.utc(2004, 04, 23)
        ..director = tarantino
        ..genre = 'action'
        ..rating = 8.0;

      pulpFiction = new Movie()
        ..title = 'Pulp Fiction'
        ..releaseDate = new DateTime.utc(1994, 12, 25)
        ..genre = 'crime'
        ..rating = 9.0;

      theHobbit = new AnimatedMovie()
        ..title = 'The Hobbit: An Unexpected Journey'
        ..releaseDate = new DateTime.utc(2012, 12, 12)
        ..genre = 'adventure'
        ..rating = 8.0
        ..cast = [freeman, mcKellen];

      session.store(armitage);
      session.store(freeman);
      session.store(mcKellen);
      session.store(tarantino);
      session.store(killBill2);
      session.store(pulpFiction);
      await session.saveChanges();
    });

    it('should attach the entity after it is created', () async {
      session.store(avatar);
      await session.saveChanges();

      expect(session.entityId(avatar)).toBeNotNull();
    });

    it('should set the id property to the entityId if it exists', () async {
      session.store(abbington);
      await session.saveChanges();

      expect(abbington.id).toEqual(session.entityId(abbington));
    });

    it('should fire events after an entity is created', () async {
      session.store(avatar);

      session.onOperation.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(avatar));
        expect(operation.type).toBe(OperationType.create);
        expect(operation.entity).toBe(avatar);
      }));
      session.onCreated.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(avatar));
        expect(operation.type).toBe(OperationType.create);
        expect(operation.entity).toBe(avatar);
      }));
      session.onUpdated.listen((_) => throw 'should not be called');
      session.onDeleted.listen((_) => throw 'should not be called');

      await session.saveChanges();
    });

    it('should be able to get an entity after it is created' , () async {
      session.store(avatar);
      await session.saveChanges();
      var get = await repository.get(session.entityId(avatar));

      expect(get).toHaveSameProps(avatar);
      expect(get).toBeA(AnimatedMovie);
    });

    it('should validate the entity before it is created' , () {
      expect(() => session.store(new Movie())).toThrowWith(type: ValidationError);
    });

    it('should be able to create entitites with a one to one relation' , () async {
      session.store(killBill);
      await session.saveChanges();
      var get = await repository.get(session.entityId(killBill));

      expect(get).toBeA(Movie);
      expect(get.title).toEqual('Kill Bill - Vol. 1');
      expect(get.director).toBeA(Person);
      expect(get.director.name).toEqual('Quentin Tarantino');
    });

    it('should be able to create entitites with a one to many relation' , () async {
      session.store(theHobbit);
      await session.saveChanges();
      var get = await repository.get(session.entityId(theHobbit));

      expect(get).toBeA(AnimatedMovie);
      expect(get.cast.map((m) => m.name).toList()..sort()).toEqual([
        'Ian McKellen',
        'Martin Freeman',
      ]);

      for (var actor in get.cast) {
        expect(actor).toBeA(Person);
      }
    });

    it('should fire events after an entity is updated', () async {
      pulpFiction..title = 'Avatar 2';
      session.store(pulpFiction);

      session.onOperation.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(pulpFiction));
        expect(operation.type).toBe(OperationType.update);
        expect(operation.entity).toBe(pulpFiction);
      }));
      session.onUpdated.listen(expectAsync((operation) {
        expect(operation.id).toEqual(session.entityId(pulpFiction));
        expect(operation.type).toBe(OperationType.update);
        expect(operation.entity).toBe(pulpFiction);
      }));
      session.onCreated.listen((_) => throw 'should not be called');
      session.onDeleted.listen((_) => throw 'should not be called');

      await session.saveChanges();
    });

    it('should be able to get an updated entity after it is updated' , () async {
      pulpFiction..title = 'Avatar 2';
      session.store(pulpFiction);
      await session.saveChanges();
      var get = await repository.get(session.entityId(pulpFiction));

      expect(get).toHaveSameProps(pulpFiction);
      expect(get).toBeA(Movie);
    });

    it('should validate the entity before it is updated' , () {
      expect(() => session.store(pulpFiction..title = null)).toThrowWith(type: ValidationError);
    });

    it('should be able to set a relation' , () async {
      pulpFiction..director = tarantino;
      session.store(pulpFiction);
      await session.saveChanges();
      var get = await repository.get(session.entityId(pulpFiction));

      expect(get).toBeA(Movie);
      expect(get.title).toEqual('Pulp Fiction');
      expect(get.director).toBeA(Person);
      expect(get.director.name).toEqual('Quentin Tarantino');
    });

    it('should be able to remove a relation' , () async {
      killBill2..director = null;
      session.store(killBill2);
      await session.saveChanges();
      var get = await repository.get(session.entityId(killBill2));

      expect(get).toBeA(Movie);
      expect(get.title).toEqual('Kill Bill - Vol. 2');
      expect(get.director).toBeNull();
    });

    it('should be able to change a relation' , () async {
      var newPerson = new Person()..name = 'Tarantino';
      killBill2..director = newPerson;

      session.store(newPerson);
      session.store(killBill2);
      await session.saveChanges();
      var get = await repository.get(session.entityId(killBill2));

      expect(get).toBeA(Movie);
      expect(get.title).toEqual('Kill Bill - Vol. 2');
      expect(get.director).toBeA(Person);
      expect(get.director.name).toEqual('Tarantino');
    });

    describe('update one to many', () {
      beforeEach(() async {
        session.store(theHobbit);
        await session.saveChanges();
      });

      it('should be able to add to a one to many relation' , () async {
        theHobbit.cast.add(armitage);

        session.store(theHobbit);
        await session.saveChanges();

        var get = await repository.get(session.entityId(theHobbit));
        expect(get).toBeA(AnimatedMovie);
        expect(get.cast.map((m) => m.name).toList()..sort()).toEqual([
          'Ian McKellen',
          'Martin Freeman',
          'Richard Armitage',
        ]);

        for (var actor in get.cast) {
          expect(actor).toBeA(Person);
        }
      });

      it('should be able to remove from a one to many relation' , () async {
        theHobbit.cast.remove(mcKellen);
        session.store(theHobbit);
        await session.saveChanges();
        var get = await repository.get(session.entityId(theHobbit));

        expect(get).toBeA(AnimatedMovie);
        expect(get.cast.map((m) => m.name).toList()..sort()).toEqual([
          'Martin Freeman',
        ]);

        for (var actor in get.cast) {
          expect(actor).toBeA(Person);
        }
      });

      it('should be able to replace one entity in a one to many relation' , () async {
        theHobbit.cast.sort((a, b) => a.name.compareTo(b.name));
        theHobbit.cast[0] = armitage;
        session.store(theHobbit);
        await session.saveChanges();
        var get = await repository.get(session.entityId(theHobbit));

        expect(get).toBeA(AnimatedMovie);
        expect(get.cast.map((m) => m.name).toList()..sort()).toEqual([
          'Martin Freeman',
          'Richard Armitage',
        ]);

        for (var actor in get.cast) {
          expect(actor).toBeA(Person);
        }
      });
    });

    it('should support mixins', () async {
      var repository = repositoryFactory(session, Base);
      var entity = new Child()
        ..baseValue = new GeoPoint(5, 10)
        ..mixinValue = 'mixin';

      session.store(entity);
      await session.saveChanges();
      var get = await repository.find({'mixinValue': 'mixin'});

      expect(get).toHaveSameProps(entity);
    });

    it('should support default values', () async {
      var repository = repositoryFactory(session, DefaultValue);
      var entity = new DefaultValue();

      session.store(entity);
      await session.saveChanges();
      var get = await repository.find({'defaultValue': 'default'});

      expect(get).toHaveSameProps(entity);
    });

    it('should support overwriting default values', () async {
      var repository = repositoryFactory(session, DefaultValue);
      var entity = new DefaultValue()..defaultValue = 'changed';

      session.store(entity);
      await session.saveChanges();
      var get = await repository.find({'defaultValue': 'changed'});

      expect(get).toHaveSameProps(entity);
    });

    it('should support private values via getters and setters', () async {
      var repository = repositoryFactory(session, PrivateValue);
      var entity = new PrivateValue()..private = 'exposed private';

      session.store(entity);
      await session.saveChanges();
      var get = await repository.find({'private': 'exposed private'});

      expect(get).toHaveSameProps(entity);
    });

    it('should support only getters', () async {
      var repository = repositoryFactory(session, OnlyGetter);
      var entity = new OnlyGetter();

      session.store(entity);
      await session.saveChanges();
      var get = await repository.find({'finalField': 'final'});
      var get2 = await repository.find({'getter': 'getter'});

      expect(get).toHaveSameProps(entity);
      expect(get2).toHaveSameProps(entity);
    });

    it('should not store ignored fields', () async {
      avatar.ageRating = 11;
      session.store(avatar);
      await session.saveChanges();

      var get = await repository.find({'ageRating': 11});
      expect(get).toBeNull();
    });
  });
}
