library warehouse.test.datatypes;

import 'package:guinness/guinness.dart';
import 'package:warehouse/warehouse.dart';

main() {
  describe('GeoPoint', () {
    it ('should be equal on equal values', () {
      var a = const GeoPoint(5, 2);
      var b = new GeoPoint(5, 2);
      var c = new GeoPoint(5, 2);

      expect(a).not.toBe(b);
      expect(b).not.toBe(c);
      expect(a).toEqual(b);
      expect(a).toEqual(c);
      expect(a).toHaveSameProps(b);
      expect(a).toHaveSameProps(c);
      expect(a.hashCode).toEqual(b.hashCode);
      expect(a.hashCode).toEqual(c.hashCode);
    });

    it ('should be not equal on different values', () {
      var a = new GeoPoint(5, 2);
      var b = new GeoPoint(5, 3);
      var c = new GeoPoint(4, 2);
      var d = new GeoPoint(2, 5);

      expect(a).not.toEqual(b);
      expect(a).not.toHaveSameProps(b);
      expect(a.hashCode).not.toEqual(b.hashCode);

      expect(a).not.toEqual(c);
      expect(a).not.toHaveSameProps(c);
      expect(a.hashCode).not.toEqual(c.hashCode);

      expect(a).not.toEqual(d);
      expect(a).not.toHaveSameProps(d);
      expect(a.hashCode).not.toEqual(d.hashCode);
    });
  });
}
