library warehouse.test.conformance.find;

import 'package:guinness/guinness.dart';
import 'package:warehouse/warehouse.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';
import '../domain.dart';

runFindTests(SessionFactory sessionFactory, RepositoryFactory repositoryFactory) {
  describe('', () {
    DbSession session = sessionFactory();
    Repository movieRepository, personRepository;
    Movie avatar, killBill, killBill2, pulpFiction, theHobbit;
    var recent =  new DateTime.utc(2009, 12, 18);

    beforeEach(() async {
      session = sessionFactory();
      movieRepository = repositoryFactory(session, Movie);
      personRepository = repositoryFactory(session, Person);

      var tarantino = new Person()
        ..name = 'Quentin Tarantino';

      avatar = new AnimatedMovie()
        ..title = 'Avatar'
        ..releaseDate = new DateTime.utc(2009, 12, 18)
        ..genre = 'action'
        ..genres = ['action', 'adventure', 'fantasy']
        ..rating = 7.9
        ..animationTechnique = AnimationTechnique.computer;

      killBill = new Movie()
        ..title = 'Kill Bill - Vol. 1'
        ..releaseDate = new DateTime.utc(2003, 12, 3)
        ..director = tarantino
        ..genre = 'action'
        ..genres = ['action']
        ..rating = 8.1;

      killBill2 = new Movie()
        ..title = 'Kill Bill - Vol. 2'
        ..releaseDate = new DateTime.utc(2004, 04, 23)
        ..director = tarantino
        ..genre = 'action'
        ..genres = ['action']
        ..rating = 8.0;

      pulpFiction = new Movie()
        ..title = 'Pulp Fiction'
        ..releaseDate = new DateTime.utc(1994, 12, 25)
        ..director = tarantino
        ..genre = 'crime'
        ..genres = ['crime']
        ..rating = 9.0;

      theHobbit = new AnimatedMovie()
        ..title = 'The Hobbit: An Unexpected Journey'
        ..releaseDate = new DateTime.utc(2012, 12, 12)
        ..genre = 'adventure'
        ..genres = ['adventure']
        ..rating = 8.0
        ..animationTechnique = AnimationTechnique.computer;

      if (!session.supportsListsAsProperty) {
        avatar.genres = null;
        killBill.genres = null;
        killBill2.genres = null;
        pulpFiction.genres = null;
        theHobbit.genres = null;
      }

      session.store(tarantino);
      session.store(avatar);
      session.store(killBill);
      session.store(killBill2);
      session.store(pulpFiction);
      session.store(theHobbit);

      await session.saveChanges();
    });

    describe('find', () {
      it('should be able to find an entity by a property', () async {
        var entity = await movieRepository.find({'title' : 'Avatar'});

        expect(entity).toHaveSameProps(avatar);
      });

      it('should be able to find an entity by a matcher', () async {
        var entity = await movieRepository.find({'title' : DO.match('Av.*')});

        expect(entity).toHaveSameProps(avatar);
      });

      it('should get directly connected entities', () async {
        // Depending on the database model this may be a relation, join or embedded.
        // All models should default to include at least the directly connected entities when
        // getting a single entity. How deeper connections are handled depends on the model.

        var entity = await movieRepository.find({'title': 'Pulp Fiction'});

        expect(entity.title).toEqual('Pulp Fiction');
        expect(entity.releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
        expect(entity.director).toBeA(Person);
        expect(entity.director.name).toEqual('Quentin Tarantino');
      });

      it('should set the id property to the entityId if it exists', () async {
        var entity = await personRepository.find({'name' : 'Quentin Tarantino'});

        expect(entity.id).toEqual(session.entityId(entity));
      });
    });

    describe('findAll', () {
      it('should be able to find all entities by the supertype', () async {
        var entities = await movieRepository.findAll(sort: 'title');

        expect(entities.length).toEqual(5);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1].title).toEqual('Kill Bill - Vol. 1');
        expect(entities[1].releaseDate).toEqual(new DateTime.utc(2003, 12, 3));
        expect(entities[1].genre).toEqual('action');
        expect(entities[2].title).toEqual('Kill Bill - Vol. 2');
        expect(entities[2].releaseDate).toEqual(new DateTime.utc(2004, 04, 23));
        expect(entities[2].genre).toEqual('action');
        expect(entities[3].title).toEqual('Pulp Fiction');
        expect(entities[3].releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
        expect(entities[3].genre).toEqual('crime');
        expect(entities[4]).toHaveSameProps(theHobbit);
      });

      it('should support polymorphyism', () async {
        var entities = await movieRepository.findAll(sort: 'title');

        expect(entities[0]).toBeA(AnimatedMovie);
        expect(entities[4]).toBeA(AnimatedMovie);
      });

      it('should be able to find all entities by a subtype', () async {
        var entities = await movieRepository.findAll(types: [AnimatedMovie], sort: 'title');

        expect(entities.length).toEqual(2);
        expect(entities[0]).toHaveSameProps(avatar);
        expect(entities[1]).toHaveSameProps(theHobbit);
      });

      it('same entity should have only one instance', () async {
        var entities = await movieRepository.findAll(where:
          {'title': IS.inList(['Kill Bill - Vol. 1', 'Pulp Fiction'])}
        );

        expect(entities[0].director).toBe(entities[1].director);
      });

      it('should be able to sort the entities', () async {
        var entities = await movieRepository.findAll(sort: 'releaseDate');

        expect(entities.length).toEqual(5);
        expect(entities[0].title).toEqual('Pulp Fiction');
        expect(entities[0].releaseDate).toEqual(new DateTime.utc(1994, 12, 25));
        expect(entities[0].genre).toEqual('crime');
        expect(entities[1].title).toEqual('Kill Bill - Vol. 1');
        expect(entities[1].releaseDate).toEqual(new DateTime.utc(2003, 12, 3));
        expect(entities[1].genre).toEqual('action');
        expect(entities[2].title).toEqual('Kill Bill - Vol. 2');
        expect(entities[2].releaseDate).toEqual(new DateTime.utc(2004, 04, 23));
        expect(entities[2].genre).toEqual('action');
        expect(entities[3]).toHaveSameProps(avatar);
        expect(entities[4]).toHaveSameProps(theHobbit);
      });

      describe('where', () {
        it('should be able to find by equal values', () async {
          var entities = await movieRepository.findAll(where: {'rating': 8.0});
          var entities2 = await movieRepository.findAll(where: {'rating': DO == 8.0});
          var entities3 = await movieRepository.findAll(where: {'rating': IS == 8.0});
          var entities4 = await movieRepository.findAll(where: {'rating': IS.equalTo(8.0)});

          expect(entities).toHaveSameProps(entities2);
          expect(entities).toHaveSameProps(entities3);
          expect(entities).toHaveSameProps(entities4);
          expect(entities.length).toEqual(2);

          // Order may not be guaranteed by the database
          entities.sort((a, b) => a.title.compareTo(b.title));

          expect(entities[0].title).toEqual('Kill Bill - Vol. 2');
          expect(entities[0].releaseDate).toEqual(new DateTime.utc(2004, 04, 23));
          expect(entities[0].genre).toEqual('action');
          expect(entities[1].title).toEqual('The Hobbit: An Unexpected Journey');
          expect(entities[1].releaseDate).toEqual(new DateTime.utc(2012, 12, 12));
          expect(entities[1].genre).toEqual('adventure');
        });

        it('should be able to find by not equal values', () async {
          var entities = await movieRepository.findAll(where: {'rating': DO.not == 8.0});
          var entities2 = await movieRepository.findAll(where: {'rating': IS.not == 8.0});
          var entities3 = await movieRepository.findAll(where: {'rating': IS.not.equalTo(8.0)});

          expect(entities).toHaveSameProps(entities2);
          expect(entities).toHaveSameProps(entities3);

          expect(entities.map((m) => m.title).toList()..sort()).toEqual([
            'Avatar',
            'Kill Bill - Vol. 1',
            'Pulp Fiction',
          ]);
        });

        it('should be able to find by values less than', () async {
          var entities = await movieRepository.findAll(where: {'releaseDate': IS < recent});
          var entities2 = await movieRepository.findAll(where: {'releaseDate': IS.lessThan(recent)});

          expect(entities).toHaveSameProps(entities2);
          expect(entities.map((m) => m.title).toList()..sort()).toEqual([
            'Kill Bill - Vol. 1',
            'Kill Bill - Vol. 2',
            'Pulp Fiction',
          ]);
        });

        it('should be able to find by values less than or equal to', () async {
          var entities = await movieRepository.findAll(where: {'releaseDate': IS <= recent});
          var entities2 = await movieRepository.findAll(where: {'releaseDate': IS.lessThanOrEqualTo(recent)});

          expect(entities).toHaveSameProps(entities2);

          // Order may not be guaranteed by the database
          entities.sort((a, b) => a.title.compareTo(b.title));

          expect(entities[0]).toHaveSameProps(avatar);
          expect(entities.map((m) => m.title).toList()..sort()).toEqual([
            'Avatar',
            'Kill Bill - Vol. 1',
            'Kill Bill - Vol. 2',
            'Pulp Fiction',
          ]);
        });

        it('should be able to find by values greater than', () async {
          var entities = await movieRepository.findAll(where: {'releaseDate': IS > recent});
          var entities2 = await movieRepository.findAll(where: {'releaseDate': IS.greaterThan(recent)});

          expect(entities).toHaveSameProps(entities2);
          expect(entities.length).toEqual(1);
          expect(entities[0]).toHaveSameProps(theHobbit);
        });

        it('should be able to find by values greater than or equal to', () async {
          var entities = await movieRepository.findAll(where: {'releaseDate': IS >= recent});
          var entities2 = await movieRepository.findAll(where: {'releaseDate': IS.greaterThanOrEqualTo(recent)});

          expect(entities).toHaveSameProps(entities2);
          expect(entities.length).toEqual(2);

          // Order may not be guaranteed by the database
          entities.sort((a, b) => a.title.compareTo(b.title));

          expect(entities[0]).toHaveSameProps(avatar);
          expect(entities[1]).toHaveSameProps(theHobbit);
        });

        it('should be able to find by values in a range', () async {
          var entities = await movieRepository.findAll(where: {'rating': IS.inRange(8, 9)});

          // Order may not be guaranteed by the database
          entities.sort((a, b) => a.title.compareTo(b.title));
          expect(entities[3]).toHaveSameProps(theHobbit);
          expect(entities.map((m) => m.title).toList()..sort()).toEqual([
            'Kill Bill - Vol. 1',
            'Kill Bill - Vol. 2',
            'Pulp Fiction',
            'The Hobbit: An Unexpected Journey',
          ]);
        });

        it('should be able to find by string containing', () async {
          var entities = await movieRepository.findAll(where: {'genre': DO.contain('ac')}, sort: 'title');

          expect(entities.length).toEqual(3);
          expect(entities[0]).toHaveSameProps(avatar);
          expect(entities[1].title).toEqual('Kill Bill - Vol. 1');
          expect(entities[1].releaseDate).toEqual(new DateTime.utc(2003, 12, 3));
          expect(entities[1].genre).toEqual('action');
          expect(entities[2].title).toEqual('Kill Bill - Vol. 2');
          expect(entities[2].releaseDate).toEqual(new DateTime.utc(2004, 04, 23));
          expect(entities[2].genre).toEqual('action');
        });

        if (session.supportsListsAsProperty) {
          it('should be able to find by list containing', () async {
            var entities = await movieRepository.findAll(where: {'genres': list.contains('action')}, sort: 'title');

            expect(entities.length).toEqual(3);
            expect(entities[0]).toHaveSameProps(avatar);
            expect(entities[1].title).toEqual('Kill Bill - Vol. 1');
            expect(entities[1].releaseDate).toEqual(new DateTime.utc(2003, 12, 3));
            expect(entities[1].genres).toEqual(['action']);
            expect(entities[2].title).toEqual('Kill Bill - Vol. 2');
            expect(entities[2].releaseDate).toEqual(new DateTime.utc(2004, 04, 23));
            expect(entities[2].genres).toEqual(['action']);
          });
        }

        it('should be able to find by values in a list', () async {
          var entities = await movieRepository.findAll(where: {'title': IS.inList(['Avatar', 'Pulp Fiction'])});

          expect(entities.length).toEqual(2);

          // Order may not be guaranteed by the database
          entities.sort((a, b) => a.title.compareTo(b.title));

          expect(entities[0]).toHaveSameProps(avatar);
          expect(entities[1].title).toEqual('Pulp Fiction');
        });

        it('should be able to find by properties that exists', () async {
          var entities = await movieRepository.findAll(where: {'animationTechnique': DO.exist});

          // Order may not be guaranteed by the database
          entities.sort((a, b) => a.title.compareTo(b.title));

          expect(entities[0].title).toEqual('Avatar');
          expect(entities[1].title).toEqual('The Hobbit: An Unexpected Journey');
        });

        it('should be able to find values that matches a regex', () async {
          var entities = await movieRepository.findAll(where: {'title': DO.match('Kill.*')});

          expect(entities.map((m) => m.title).toList()..sort()).toEqual([
            'Kill Bill - Vol. 1',
            'Kill Bill - Vol. 2',
          ]);
        });

        it('should be able to negate other filters', () async {
          var entities = await movieRepository.findAll(where: {'releaseDate': IS.not > recent});
          var entities2 = await movieRepository.findAll(where: {'releaseDate': IS.not(IS > recent)});

          expect(entities).toHaveSameProps(entities2);
          expect(entities.map((m) => m.title).toList()..sort()).toEqual([
            'Avatar',
            'Kill Bill - Vol. 1',
            'Kill Bill - Vol. 2',
            'Pulp Fiction'
          ]);

          entities = await movieRepository.findAll(where: {'title': IS.not.inList(['Avatar', 'Fury'])});
          entities2 = await movieRepository.findAll(where: {'title': IS.not(IS.inList(['Avatar', 'Fury']))});

          expect(entities).toHaveSameProps(entities2);
          expect(entities.map((m) => m.title).toList()..sort()).toEqual([
            'Kill Bill - Vol. 1',
            'Kill Bill - Vol. 2',
            'Pulp Fiction',
            'The Hobbit: An Unexpected Journey',
          ]);
        });
      });
    });
  });
}
