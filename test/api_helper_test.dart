import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import 'package:beermonopoly/services/api.dart';
import 'package:beermonopoly/utils/exceptions.dart';
import 'package:beermonopoly/providers/filter.dart';
import 'package:beermonopoly/models/stock_change.dart';
import 'package:beermonopoly/models/product.dart';

class MockClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockClient mockClient;
  late Filter filter;

  setUp(() {
    mockClient = MockClient();
    filter = Filter();
    registerFallbackValue(FakeUri());
  });

  group(
    'checkStock',
    () {
      test(
        "raises ApiException when not receiving status code 200",
        () async {
          when(() => mockClient.get(any())).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.checkStock(mockClient, '1,2,3', '110'),
            throwsA(
              isA<ApiException>(),
            ),
          );
        },
      );

      test(
        "raises NetworkException on SocketException",
        () async {
          when(() => mockClient.get(any())).thenAnswer(((_) async {
            throw const SocketException('No connection');
          }));

          expect(
            () => ApiHelper.checkStock(mockClient, '1,2,3', '110'),
            throwsA(
              isA<NetworkException>(),
            ),
          );
        },
      );
      test(
        "check stock of two beers in one store",
        () async {
          when(() => mockClient.get(
                Uri.parse('https://api.example.com/'),
              )).thenAnswer(((_) async {
            return http.Response(
              '{"count":2,"next":null,"previous":null,"results":[{"vmp_id":1053802,"stock":8},{"vmp_id":1336902,"stock":7}]}',
              200,
            );
          }));

          final stock =
              await ApiHelper.checkStock(mockClient, '1053802,1336902', '121');

          expect(stock, [
            {'vmp_id': 1053802, 'stock': 8},
            {'vmp_id': 1336902, 'stock': 7}
          ]);
        },
      );
    },
  );

  group(
    'getStockChangeList',
    () {
      test(
        "raises ApiException when not receiving status code 200",
        () async {
          when(() => mockClient.get(
                any(),
              )).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.getStockChangeList(mockClient, 1, 25, '121'),
            throwsA(
              isA<ApiException>(),
            ),
          );
        },
      );

      test(
        "raises NetworkException on SocketException",
        () async {
          when(() => mockClient.get(
                any(),
              )).thenAnswer(((_) async {
            throw const SocketException('No connection');
          }));

          expect(
            () => ApiHelper.getStockChangeList(mockClient, 1, 25, '121'),
            throwsA(
              isA<NetworkException>(),
            ),
          );
        },
      );

      test(
        "get stock change from store when not signed in",
        () async {
          when(() => mockClient.get(
                Uri.parse(
                  'https://api.example.com/',
                ),
              )).thenAnswer(((_) async {
            return http.Response(
              """
            {
              "count": 322,
              "next": "http://api.beermonopoly.com/stockchange/?page=2&page_size=1&store=472",
              "previous": null,
              "results": [
                {
                  "store": 472,
                  "quantity": 21,
                  "stock_updated": "2024-01-06T00:16:49.751890+01:00",
                  "stocked_at": "2024-01-06T00:16:49.751471+01:00",
                  "unstocked_at": null,
                  "beer": {
                    "vmp_id": 16655102,
                    "vmp_name": "Parish Ghost In The Machine DIPA",
                    "price": 174.9,
                    "style": "IPA - Imperial / Double New England / Hazy",
                    "volume": 0.473
                  }
                }
              ]
            }
            """,
              200,
            );
          }));

          final stockChangeList =
              await ApiHelper.getStockChangeList(mockClient, 1, 1, '472');

          expect(
            stockChangeList,
            [
              StockChange(
                store: '472',
                quantity: 21,
                stockUpdated:
                    DateTime.parse("2024-01-06T00:16:49.751890+01:00"),
                stockedAt: DateTime.parse("2024-01-06T00:16:49.751471"),
                unstockedAt: null,
                stockUnstockAt: DateTime.parse("2024-01-06T00:16:49.751471"),
                product: const Product(
                  id: 16655102,
                  name: "Parish Ghost In The Machine DIPA",
                  style: "IPA - Imperial / Double New England / Hazy",
                  price: 174.9,
                  volume: 0.473,
                ),
              )
            ],
          );
        },
      );
    },
  );

  group(
    'getProductList',
    () {
      test(
        "raises ApiException when not receiving status code 200",
        () async {
          when(() => mockClient.get(
                any(),
              )).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.getProductList(mockClient, 1, filter, 25),
            throwsA(
              isA<ApiException>(),
            ),
          );
        },
      );

      test(
        "raises NetworkException on SocketException",
        () async {
          when(() => mockClient.get(
                any(),
              )).thenAnswer(((_) async {
            throw const SocketException('No connection');
          }));

          expect(
            () => ApiHelper.getProductList(mockClient, 1, filter, 25),
            throwsA(
              isA<NetworkException>(),
            ),
          );
        },
      );

      test(
        "get product list when not signed in with filter and alternative style",
        () async {
          filter.style = 'mead';
          filter.ppvLow = '2.3';
          when(() => mockClient.get(
                Uri.parse(
                  'https://api.example.com/',
                ),
              )).thenAnswer(((_) async {
            return http.Response(
              """
            {
              "count": 3661,
              "next": "http://api.beermonopoly.com/beers/?abv_high=&abv_low=&active=True&country=&exclude_allergen=&fields=vmp_id%2Cvmp_name%2Cprice%2Crating%2Ccheckins%2Clabel_sm_url%2Cmain_category%2Csub_category%2Cstyle%2Cstock%2Cabv%2Cuser_checked_in%2Cuser_wishlisted%2Cvolume%2Cprice_per_volume%2Cvmp_url%2Cuntpd_url%2Cuntpd_id%2Ccountry%2Cproduct_selection&ordering=-rating&page=2&page_size=1&ppv_high=&ppv_low=&price_high=&price_low=&product_selection=&release=&search=&style=",
              "previous": null,
              "results": [
                {
                  "vmp_id": 16655602,
                  "untpd_id": 5575146,
                  "vmp_name": "Marlobobo Wildberry Vanilla Trail 2022",
                  "country": "Norge",
                  "product_selection": "Tilleggsutvalget",
                  "price": 384.8,
                  "volume": 0.375,
                  "price_per_volume": 1026.1333333333334,
                  "abv": 12.5,
                  "rating": 4.72213,
                  "checkins": 61,
                  "main_category": "Mjod",
                  "vmp_url": "https://www.vinmonopolet.no/Land/Norge/Vestfold-og-Telemark/Holmestrand/Marlobobo-Wildberry-Vanilla-Trail-2022/p/16655602",
                  "untpd_url": "https://untappd.com/b/marlobobo-wildberry-vanilla-trail-2022/5575146",
                  "label_sm_url": "https://assets.untappd.com/site/beer_logos/beer-5575146_aafa4_sm.jpeg",
                  "user_checked_in": [],
                  "user_wishlisted": false,
                  "stock": null
                }
              ]
            }
            """,
              200,
            );
          }));

          final productList =
              await ApiHelper.getProductList(mockClient, 1, filter, 1);

          expect(
            productList,
            [
              const Product(
                id: 16655602,
                untappdId: 5575146,
                name: "Marlobobo Wildberry Vanilla Trail 2022",
                country: "Norge",
                productSelection: "Tilleggsutvalget",
                style: "Mjod",
                price: 384.8,
                volume: 0.375,
                pricePerVolume: 1026.1333333333334,
                abv: 12.5,
                imageUrl:
                    "https://assets.untappd.com/site/beer_logos/beer-5575146_aafa4_sm.jpeg",
                rating: 4.72213,
                checkins: 61,
                vmpUrl:
                    "https://www.vinmonopolet.no/Land/Norge/Vestfold-og-Telemark/Holmestrand/Marlobobo-Wildberry-Vanilla-Trail-2022/p/16655602",
                untappdUrl:
                    "https://untappd.com/b/marlobobo-wildberry-vanilla-trail-2022/5575146",
                stock: null,
              ),
            ],
          );
        },
      );
    },
  );

  group(
    'getProductsData',
    () {
      test(
        "raises ApiException when not receiving status code 200",
        () async {
          when(() => mockClient.get(
                any(),
              )).thenAnswer(((_) async {
            return http.Response('', 400);
          }));

          expect(
            () => ApiHelper.getProductsData(mockClient, '1,2,3'),
            throwsA(
              isA<ApiException>(),
            ),
          );
        },
      );

      test(
        "raises NetworkException on SocketException",
        () async {
          when(() => mockClient.get(
                any(),
              )).thenAnswer(((_) async {
            throw const SocketException('No connection');
          }));

          expect(
            () => ApiHelper.getProductsData(mockClient, '1,2,3'),
            throwsA(
              isA<NetworkException>(),
            ),
          );
        },
      );
    },
  );
}
