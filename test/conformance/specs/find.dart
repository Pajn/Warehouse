library warehouse.test.conformance.find;

import 'package:guinness/guinness.dart';
import 'package:warehouse/warehouse.dart';
import '../domain.dart';

runFindTests(DbSession session) {
  Movie avatar, killBill, pulpFiction, theHobbit;
  var recent =  new DateTime(2009, 12, 18);

  beforeEach(() async {
    var tarantino = new Person()
      ..name = 'Quentin Tarantino';

    avatar = new Movie()
      ..title = 'Avatar'
      ..releaseDate = new DateTime(2009, 12, 18)
      ..genre = 'action'
      ..rating = 7.9;

    killBill = new Movie()
      ..title = 'Kill Bill - Vol. 1'
      ..releaseDate = new DateTime(2003, 12, 3)
      ..director = tarantino
      ..genre = 'action'
      ..rating = 8.1;

    pulpFiction = new Movie()
      ..title = 'Pulp Fiction'
      ..releaseDate = new DateTime(1994, 12, 25)
      ..director = tarantino
      ..genre = 'crime'
      ..rating = 8.9;

    theHobbit = new Movie()
      ..title = 'The Hobbit: An Unexpected Journey'
      ..releaseDate = new DateTime(2012, 12, 12)
      ..genre = 'adventure'
      ..rating = 8.0;

    session.store(avatar);
    session.store(killBill);
    session.store(pulpFiction);
    session.store(theHobbit);

    await session.saveChanges();
  });

  describe('find', () {
    it('should be able to find an entity by a property', () async {
      var entity = await session.find({'name' : 'Avatar'});

      expect(entity).toHaveSameProps(avatar);
    });

    it('should be able to find an entity by a matcher', () async {
      var entity = await session.find({'name' : DO.match('Av.*')});

      expect(entity).toHaveSameProps(avatar);
    });

    it('should get directly connected entities', () async {
      // Depending on the database model this may be a relation, join or embedded.
      // All models should default to include at least the directly connected entities when
      // getting a single entity. How deeper connections are handled depends on the model.

      var entity = await session.find({'name': 'Pulp Fiction'});

      expect(entity.title).toEqual('Pulp Fuction');
      expect(entity.releaseDate).toEqual(new DateTime.now());
      expect(entity.director).toBeA(Person);
      expect(entity.director.name).toEqual('Quentin Tarantino');
    });
  });

  describe('findAll', () {
    // findAll without parameters differs in behaviour between models.
    // A graph database would return all entities where a document database would embed
    // the person entities into the movie entities and only return the movies.
    // TODO: How should multiple collections/tables be handled when one can't query everything at once?

    it('should be able to find all entities by a type', () async {
      var entities = await session.findAll(type: Movie);

      expect(entities.length).toEqual(4);
      expect(entities[0]).toHaveSameProps(avatar);
      expect(entities[1].title).toEqual('Kill Bill - Vol. 1');
      expect(entities[1].releaseDate).toEqual(new DateTime(2003, 12, 3));
      expect(entities[1].genre).toEqual('action');
      expect(entities[2].title).toEqual('Pulp Fuction');
      expect(entities[2].releaseDate).toEqual(new DateTime(1994, 12, 25));
      expect(entities[2].genre).toEqual('crime');
      expect(entities[3]).toHaveSameProps(theHobbit);
    });

    it('should be able to sort the entities', () async {
      var entities = await session.findAll(type: Movie, sort: 'releaseDate');

      expect(entities.length).toEqual(4);
      expect(entities[0].title).toEqual('Pulp Fuction');
      expect(entities[0].releaseDate).toEqual(new DateTime(1994, 12, 25));
      expect(entities[0].genre).toEqual('crime');
      expect(entities[1].title).toEqual('Kill Bill - Vol. 1');
      expect(entities[1].releaseDate).toEqual(new DateTime(2003, 12, 3));
      expect(entities[1].genre).toEqual('action');
      expect(entities[2]).toHaveSameProps(avatar);
      expect(entities[3]).toHaveSameProps(theHobbit);
    });

    describe('where', () {
      it('should be able to find by equal values', () async {
        var entities = await session.findAll(where: {'genre': 'Action'});
        var entities2 = await session.findAll(where: {'genre': DO == 'Action'});
        var entities3 = await session.findAll(where: {'genre': IS == 'Action'});
        var entities4 = await session.findAll(where: {'genre': IS.equalTo('Action')});

        expect(entities).toHaveSameProps(entities2);
        expect(entities).toHaveSameProps(entities3);
        expect(entities).toHaveSameProps(entities4);
        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1].title).toEqual('Kill Bill - Vol. 1');
        expect(entities[1].releaseDate).toEqual(new DateTime(2003, 12, 3));
        expect(entities[1].genre).toEqual('action');
      });

      it('should be able to find by values less than', () async {
        var entities = await session.findAll(where: {'releaseDate': IS < recent});
        var entities2 = await session.findAll(where: {'releaseDate': IS.lessThan(recent)});

        expect(entities).toHaveSameProps(entities2);
        expect(entities.length).toEqual(2);
        expect(entities[0].title).toEqual('Kill Bill - Vol. 1');
        expect(entities[1].title).toEqual('Pulp Fuction');
      });

      it('should be able to find by values less than or equal to', () async {
        var entities = await session.findAll(where: {'releaseDate': IS <= recent});
        var entities2 = await session.findAll(where: {'releaseDate': IS.lessThanOrEqualTo(recent)});

        expect(entities).toHaveSameProps(entities2);
        expect(entities.length).toEqual(3);
        expect(entities[0].title).toEqual('Kill Bill - Vol. 1');
        expect(entities[1].title).toEqual('Pulp Fuction');
        expect(entities[2]).toHaveSameProps(avatar);
      });

      it('should be able to find by values greater than', () async {
        var entities = await session.findAll(where: {'releaseDate': IS > recent});
        var entities2 = await session.findAll(where: {'releaseDate': IS.greaterThan(recent)});

        expect(entities).toHaveSameProps(entities2);
        expect(entities.length).toEqual(1);
        expect(entities[0]).toHaveSameProps(theHobbit);
      });

      it('should be able to find by values greater than or equal to', () async {
        var entities = await session.findAll(where: {'releaseDate': IS >= recent});
        var entities2 = await session.findAll(where: {'releaseDate': IS.greaterThanOrEqualTo(recent)});

        expect(entities).toHaveSameProps(entities2);
        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1]).toHaveSameProps(theHobbit);
      });

      it('should be able to find by values in a range', () async {
        var entities = await session.findAll(where: {'rating': IS.inRange(8, 9)});

        expect(entities.length).toEqual(3);
        expect(entities[0].title).toEqual('Kill Bill - Vol. 1');
        expect(entities[1].title).toEqual('Pulp Fuction');
        expect(entities[2]).toHaveSameProps(theHobbit);
      });

      it('should be able to find by values in a list', () async {
        var entities = await session.findAll(where: {'name': IS.inList(['Avatar', 'Pulp Fiction'])});

        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1].title).toEqual('Pulp Fiction');
      });

      it('should be able to find by properties that exists', () async {
        var entities = await session.findAll(where: {'???': DO.exist});

        expect('expectations').toBe('written');
      });

      it('should be able to find values that matches a regex', () async {
        var entities = await session.findAll(where: {'name': DO.match('Kill.*')});

        expect(entities.length).toEqual(1);
        expect(entities[0].title).toEqual('Kill Bill - Vol. 1');
      });
    });
  });
}
