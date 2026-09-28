import 'package:flutter_test/flutter_test.dart';
import 'package:beermonopoly/providers/filter.dart';

void main() {
  test('releaseSortBySaveSetting targets releaseSortBy', () {
    expect(Filter().releaseSortBySaveSetting['name'], 'releaseSortBy');
  });
}
