class Store {
  Store({
    required this.id,
    required this.name,
    this.gpsLat,
    this.gpsLng,
    this.distance,
  });

  factory Store.fromJson(Map<String, dynamic> product) => Store(
        id: product['store_id'].toString(),
        name: product['name'],
        gpsLat: product['gps_lat'],
        gpsLng: product['gps_long'],
      );

  String id;
  String name;
  double? gpsLat;
  double? gpsLng;
  double? distance;
}
