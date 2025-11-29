import 'package:equatable/equatable.dart';

class Country extends Equatable {
  const Country({
    required this.name,
    this.isoCode,
  });

  factory Country.fromJson(Map<String, dynamic> country) => Country(
        name: country['name'],
        isoCode: country['iso_code'],
      );

  @override
  List<Object?> get props => [name, isoCode];

  final String name;
  final String? isoCode;
}
