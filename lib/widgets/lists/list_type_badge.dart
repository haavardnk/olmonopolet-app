import 'package:flutter/material.dart';

import '../../models/list_preset.dart';
import '../../models/user_list.dart';

class ListTypeBadge extends StatelessWidget {
  final bool isUntappd;
  final bool isFollowed;
  final bool showQuantity;
  final bool showStore;
  final bool showVintage;
  final bool showPrices;
  final bool showNotes;
  final bool small;

  const ListTypeBadge({
    super.key,
    required this.isUntappd,
    required this.isFollowed,
    required this.showQuantity,
    required this.showStore,
    required this.showVintage,
    required this.showPrices,
    required this.showNotes,
    this.small = false,
  });

  factory ListTypeBadge.fromList(UserList list, {Key? key, bool small = false}) =>
      ListTypeBadge(
        key: key,
        isUntappd: list.isUntappd,
        isFollowed: list.isFollowed,
        showQuantity: list.showQuantity,
        showStore: list.showStore,
        showVintage: list.showVintage,
        showPrices: list.showPrices,
        showNotes: list.showNotes,
        small: small,
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconSize = small ? 12.0 : 14.0;
    final fontSize = small ? 10.0 : 12.0;
    final hPad = small ? 6.0 : 8.0;
    final vPad = small ? 2.0 : 4.0;

    final String label;
    final IconData icon;

    if (isFollowed) {
      label = 'Følger';
      icon = Icons.bookmark_outline;
    } else if (isUntappd) {
      label = 'Untappd';
      icon = Icons.cloud_download_outlined;
    } else {
      final preset = matchPreset(
        showQuantity: showQuantity,
        showStore: showStore,
        showVintage: showVintage,
        showPrices: showPrices,
        showNotes: showNotes,
      );
      if (preset != null && preset.id != 'simple') {
        label = preset.label;
        icon = preset.icon;
      } else if (preset == null) {
        label = 'Tilpasset';
        icon = Icons.tune_outlined;
      } else {
        return const SizedBox.shrink();
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: colors.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
