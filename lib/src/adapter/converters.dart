part of warehouse.adapter;

abstract class Converter {
  toDatabase(value);
  fromDatabase(value);
}

class TimestampConverter implements Converter {
  int toDatabase(DateTime value) => value.toUtc().millisecondsSinceEpoch;
  DateTime fromDatabase(int value) => new DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);

  const TimestampConverter();
}

class GeoPointArrayConverter implements Converter {
  List<num> toDatabase(GeoPoint value) => [ value.longitude, value.latitude ];
  GeoPoint fromDatabase(List<num> value) => new GeoPoint(value[1], value[0]);

  const GeoPointArrayConverter();
}

class TypeConverter implements Converter {
  String toDatabase(Type value) {
    var tm = reflectType(value);
    var libraryName = MirrorSystem.getName(tm.owner.simpleName);
    var typeName = MirrorSystem.getName(tm.simpleName);
    return '$libraryName%$typeName';
  }

  Type fromDatabase(String value) {
    var parts = value.split('%');
    var librarySymbol = MirrorSystem.getSymbol(parts[0]);
    var typeSymbol = MirrorSystem.getSymbol(parts[1]);
    var tm = currentMirrorSystem().findLibrary(librarySymbol).declarations[typeSymbol];

    return tm.reflectedType;
  }

  const TypeConverter();
}

const TimestampConverter timestampConverter = const TimestampConverter();
const GeoPointArrayConverter geoPointArrayConverter = const GeoPointArrayConverter();
const TypeConverter typeConverter = const TypeConverter();
