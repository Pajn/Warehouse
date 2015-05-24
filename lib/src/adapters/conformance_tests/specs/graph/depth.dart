library warehouse.test.conformance.graph.depth;

import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:warehouse/adapters/base.dart';
import 'package:warehouse/graph.dart';
import 'package:warehouse/src/adapters/conformance_tests/graph_domain.dart';
import 'package:warehouse/src/adapters/conformance_tests/factories.dart';

runDepthTests(SessionFactory factory) {
  describe('depth', () {
    GraphDbSession session;
    Person abbington, freeman, jacksen, mcKellen;
    Partnership abbingtonFreeman;
    Role bilbo, gandalf, sherlock, tracy;
    Movie ghosted, kingKong, mrHolmes, theHobbit;

    beforeEach(() async {
      session = factory();

      abbington = new Actor()..name = 'Amanda Abbington';
      freeman = new Actor()..name = 'Martin Freeman';
      mcKellen = new Actor()..name = 'Ian McKellen';
      jacksen = new Director()..name = 'Peter Jackson';

      abbingtonFreeman = new Partnership()
        ..partners = [abbington]
        ..started = new DateTime.utc(2000);

      freeman.partnerships = [abbingtonFreeman];

      bilbo = new Role()
        ..role = 'Bilbo'
        ..actor = freeman;
      gandalf = new Role()
        ..role = 'Gandalf'
        ..actor = mcKellen;
      sherlock = new Role()
        ..role = 'Sherlock Holmes'
        ..actor = mcKellen;
      tracy = new Role()
        ..role = 'Tracy'
        ..actor = abbington;

      ghosted = new Movie()
        ..title = 'Ghosted'
        ..cast = [tracy];

      kingKong = new Movie()
        ..title = 'King Kong'
        ..director = jacksen;

      mrHolmes = new Movie()
        ..title = 'Mr. Holmes'
        ..cast = [sherlock];

      theHobbit = new Movie()
        ..title = 'The Hobbit: An Unexpected Journey'
        ..releaseDate = new DateTime.utc(2012, 12, 12)
        ..genres = ['adventure']
        ..rating = 8.0
        ..director = jacksen
        ..cast = [bilbo, gandalf];

      session.store(abbington);
      session.store(freeman);
      session.store(mcKellen);
      session.store(jacksen);
      session.store(ghosted);
      session.store(kingKong);
      session.store(mrHolmes);
      session.store(theHobbit);
      await session.saveChanges();
    });

    it('should be able to get no related nodes', () async {
      Movie get = await session.get(session.entityId(theHobbit), depth: 0);

      expect(get.cast).toBeNull();
      expect(get.director).toBeNull();
    });

    it('should be able to get related nodes to an arbitary depth', () async {
      Movie get = await session.get(session.entityId(theHobbit), depth: 2);

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(2);
      expect(get.director.name).toEqual('Peter Jackson');
      expect(get.director.directed.length).toEqual(2);

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));
      get.cast[1].actor.roles.sort((a, b) => a.role.compareTo(b.role));
      get.director.directed.sort((a, b) => a.title.compareTo(b.title));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles).toBeNull();
      expect(get.cast[1].actor.roles[1].movie.title).toEqual('Mr. Holmes');
      expect(get.director.directed[0].title).toEqual('King Kong');
    });

    it('should be able to get related nodes by name', () async {
      Movie get = await session.get(session.entityId(theHobbit), depth: 'cast');

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships).toBeNull();
      expect(get.director).toBeNull();
    });

    it('should be able to get related nodes by names', () async {
      Movie get = await session.get(session.entityId(theHobbit),
          depth: ['cast', 'director']);

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships).toBeNull();
      expect(get.director.name).toEqual('Peter Jackson');
      expect(get.director.directed.length).toEqual(1);
    });

    it('should be able to get deeper related nodes by name->name', () async {
      Movie get = await session.get(session.entityId(theHobbit),
          depth: {'cast': 'partnerships'});

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(1);
      expect(get.director).toBeNull();

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles).toBeNull();
    });

    it('should be able to get deeper related nodes by names->name', () async {
      Movie get = await session.get(session.entityId(theHobbit),
          depth: {['cast', 'director']: 'partnerships'});

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(1);
      expect(get.director.name).toEqual('Peter Jackson');
      expect(get.director.directed.length).toEqual(1);

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles).toBeNull();
    });

    it('should be able to get deeper related nodes by name->names', () async {
      Movie get = await session.get(session.entityId(theHobbit),
          depth: {'cast': ['partnerships', 'cast']});

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(2);
      expect(get.director).toBeNull();

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));
      get.cast[1].actor.roles.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles).toBeNull();
      expect(get.cast[1].actor.roles[1].movie.title).toEqual('Mr. Holmes');
    });

    it('should be able to get deeper related nodes by names->names', () async {
      Movie get = await session.get(session.entityId(theHobbit),
          depth: {['cast', 'director']: ['partnerships', 'cast']});

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(2);
      expect(get.director.name).toEqual('Peter Jackson');
      expect(get.director.directed.length).toEqual(1);
      expect(get.director.directed.length).toEqual(1);

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));
      get.cast[1].actor.roles.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles).toBeNull();
      expect(get.cast[1].actor.roles[1].movie.title).toEqual('Mr. Holmes');
    });

    it('should be able to get related nodes to an arbitary depth after following a name',
        () async {
      Movie get =
          await session.get(session.entityId(theHobbit), depth: {'cast': 1});

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(2);
      expect(get.director).toBeNull();

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));
      get.cast[1].actor.roles.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles).toBeNull();
      expect(get.cast[1].actor.roles[1].movie.title).toEqual('Mr. Holmes');
    });

    it('should be able to get related nodes to an arbitary depth after following names',
        () async {
      Movie get = await session.get(session.entityId(theHobbit),
          depth: {'cast': 2, 'director': 1});

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(2);
      expect(get.director.name).toEqual('Peter Jackson');
      expect(get.director.directed.length).toEqual(2);

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));
      get.cast[1].actor.roles.sort((a, b) => a.role.compareTo(b.role));
      get.director.directed.sort((a, b) => a.title.compareTo(b.title));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles.length)
          .toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners[0].roles[0].movie.title)
          .toEqual('Ghosted');
      expect(get.cast[1].actor.roles[1].movie.title).toEqual('Mr. Holmes');
      expect(get.director.directed[0].title).toEqual('King Kong');
    });

    it('should be able to get related nodes to an arbitary depth and by name',
        () async {
      Movie get = await session.get(session.entityId(theHobbit),
          depth: [1, {'cast': 'partnerships'}]);

      get.cast.sort((a, b) => a.role.compareTo(b.role));

      expect(get.cast.length).toEqual(2);
      expect(get.cast[0].role).toEqual('Bilbo');
      expect(get.cast[1].role).toEqual('Gandalf');
      expect(get.cast[0].actor.name).toEqual('Martin Freeman');
      expect(get.cast[1].actor.name).toEqual('Ian McKellen');
      expect(get.cast[0].actor.partnerships.length).toEqual(1);
      expect(get.cast[0].actor.partnerships[0].partners.length).toEqual(2);
      expect(get.cast[1].actor.roles.length).toEqual(1);
      expect(get.director.name).toEqual('Peter Jackson');
      expect(get.director.directed.length).toEqual(1);

      get.cast[0].actor.partnerships[0].partners
          .sort((a, b) => a.name.compareTo(b.name));

      expect(get.cast[0].actor.partnerships[0].partners[0].name)
          .toEqual('Amanda Abbington');
      expect(get.cast[0].actor.partnerships[0].partners[0].roles).toBeNull();
    });
  });
}
