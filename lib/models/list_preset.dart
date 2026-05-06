import 'package:flutter/material.dart';

class ListPreset {
  final String id;
  final String label;
  final IconData icon;
  final String description;
  final bool showQuantity;
  final bool showStore;
  final bool showVintage;
  final bool showPrices;

  const ListPreset({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
    required this.showQuantity,
    required this.showStore,
    required this.showVintage,
    required this.showPrices,
  });
}

const listPresets = [
  ListPreset(
    id: 'simple',
    label: 'Enkel liste',
    icon: Icons.list,
    description: 'Bare en liste med produkter',
    showQuantity: false,
    showStore: false,
    showVintage: false,
    showPrices: true,
  ),
  ListPreset(
    id: 'shopping',
    label: 'Handleliste',
    icon: Icons.shopping_cart_outlined,
    description: 'Med antall, priser og butikkstatus',
    showQuantity: true,
    showStore: true,
    showVintage: false,
    showPrices: true,
  ),
  ListPreset(
    id: 'cellar',
    label: 'Kjellerliste',
    icon: Icons.inventory_2_outlined,
    description: 'Spor årgang og lager',
    showQuantity: true,
    showStore: false,
    showVintage: true,
    showPrices: true,
  ),
];

ListPreset? matchPreset({
  required bool showQuantity,
  required bool showStore,
  required bool showVintage,
  required bool showPrices,
}) {
  for (final preset in listPresets) {
    if (preset.showQuantity == showQuantity &&
        preset.showStore == showStore &&
        preset.showVintage == showVintage &&
        preset.showPrices == showPrices) {
      return preset;
    }
  }
  return null;
}
