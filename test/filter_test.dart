import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beermonopoly/providers/filter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('releaseSortBySaveSetting targets releaseSortBy', () {
    expect(Filter().releaseSortBySaveSetting['name'], 'releaseSortBy');
  });

  for (final (selected, expected) in [
    ([1], 'can'),
    ([0, 2], 'bottle,other'),
    ([2, 0, 1], 'bottle,can,other'),
  ]) {
    test('setPackageType $selected sends "$expected" and resets', () {
      final filter = Filter();
      for (final i in selected) {
        filter.setPackageType(i, true);
      }
      expect(filter.packageType, expected);
      filter.resetPackageType();
      expect(filter.packageType, '');
      expect(filter.packageTypeSelectedList, [false, false, false]);
    });
  }
}
