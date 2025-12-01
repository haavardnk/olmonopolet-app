class ProductStats {
  final int productCount;
  final int beerCount;
  final int ciderCount;
  final int meadCount;

  ProductStats({
    required this.productCount,
    required this.beerCount,
    required this.ciderCount,
    required this.meadCount,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) => ProductStats(
        productCount: json['product_count'] ?? 0,
        beerCount: json['beer_count'] ?? 0,
        ciderCount: json['cider_count'] ?? 0,
        meadCount: json['mead_count'] ?? 0,
      );
}

class Release {
  Release({
    required this.name,
    this.releaseDate,
    required this.productSelections,
    this.productStats,
    this.isChristmasRelease = false,
  });

  factory Release.fromJson(Map<String, dynamic> release) => Release(
        name: release['name'],
        releaseDate: release['release_date'] != null
            ? DateTime.parse(release['release_date'].split("+")[0])
            : null,
        productSelections: [...release['product_selections']],
        productStats: release['product_stats'] != null
            ? ProductStats.fromJson(release['product_stats'])
            : null,
        isChristmasRelease: release['is_christmas_release'] ?? false,
      );

  String name;
  DateTime? releaseDate;
  List<String> productSelections;
  ProductStats? productStats;
  bool isChristmasRelease;
}
