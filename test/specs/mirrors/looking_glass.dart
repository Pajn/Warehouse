library warehouse.test.looking_glass;

import 'dart:mirrors';
import 'package:guinness/guinness.dart';
import 'package:warehouse/adapters/base.dart';
import 'package:warehouse/warehouse.dart';

class Reflect<T> {
  get t => reflectType(T);
}

main() {
  describe('LookingGlass', () {
    LookingGlass lg;
    beforeEach(() {
      lg = new LookingGlass();
    });

    describe('supportsTypeAsProperty', () {
      it('should report that it supports the native types', () {
        expect(lg.supportsTypeAsProperty(reflectType(bool))).toBeTrue();
        expect(lg.supportsTypeAsProperty(reflectType(num))).toBeTrue();
        expect(lg.supportsTypeAsProperty(reflectType(int))).toBeTrue();
        expect(lg.supportsTypeAsProperty(reflectType(double))).toBeTrue();
        expect(lg.supportsTypeAsProperty(reflectType(String))).toBeTrue();
      });

      it('should report that it supports the native types wrapped in lists', () {
        expect(lg.supportsTypeAsProperty(new Reflect<List<bool>>().t)).toBeTrue();
        expect(lg.supportsTypeAsProperty(new Reflect<List<num>>().t)).toBeTrue();
        expect(lg.supportsTypeAsProperty(new Reflect<List<int>>().t)).toBeTrue();
        expect(lg.supportsTypeAsProperty(new Reflect<List<double>>().t)).toBeTrue();
        expect(lg.supportsTypeAsProperty(new Reflect<List<String>>().t)).toBeTrue();
      });

      it('should report that it supports the converted types', () {
        expect(lg.supportsTypeAsProperty(reflectType(DateTime))).toBeTrue();
        expect(lg.supportsTypeAsProperty(reflectType(GeoPoint))).toBeTrue();
        expect(lg.supportsTypeAsProperty(reflectType(Type))).toBeTrue();
      });

      it('should report that it supports the converted types wrapped in lists', () {
        expect(lg.supportsTypeAsProperty(new Reflect<List<DateTime>>().t)).toBeTrue();
        expect(lg.supportsTypeAsProperty(new Reflect<List<GeoPoint>>().t)).toBeTrue();
        expect(lg.supportsTypeAsProperty(new Reflect<List<Type>>().t)).toBeTrue();
      });

      it('should report that it does not support other types', () {
        expect(lg.supportsTypeAsProperty(reflectType(Map))).toBeFalse();
        expect(lg.supportsTypeAsProperty(reflectType(Iterable))).toBeFalse();
        expect(lg.supportsTypeAsProperty(reflectType(RegExp))).toBeFalse();
      });

      it('should report that it does not support types wrapped in lists', () {
        expect(lg.supportsTypeAsProperty(new Reflect<List<Map>>().t)).toBeFalse();
        expect(lg.supportsTypeAsProperty(new Reflect<List<Iterable>>().t)).toBeFalse();
        expect(lg.supportsTypeAsProperty(new Reflect<List<List>>().t)).toBeFalse();
        expect(lg.supportsTypeAsProperty(new Reflect<List<RegExp>>().t)).toBeFalse();
        expect(lg.supportsTypeAsProperty(new Reflect<List<List<num>>>().t)).toBeFalse();
      });

      it('should throw if it encounters List<dynamic>', () {
        expect(() => lg.supportsTypeAsProperty(reflectType(List))).toThrowWith();
      });
    });

    describe('converterFor', () {
      it('should return the correct converter', () {
        expect(lg.converterFor(reflectType(DateTime))).toEqual(timestampConverter);
        expect(lg.converterFor(reflectType(GeoPoint))).toEqual(geoPointArrayConverter);
        expect(lg.converterFor(reflectType(Type))).toEqual(typeConverter);
      });

      it('should return null if the type is not converted', () {
        expect(lg.converterFor(reflectType(num))).toBeNull();
        expect(lg.converterFor(reflectType(Map))).toBeNull();
      });
    });
  });
}
