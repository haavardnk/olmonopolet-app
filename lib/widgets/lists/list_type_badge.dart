import 'package:flutter/material.dart';

import '../../models/user_list.dart';

class ListTypeBadge extends StatelessWidget {
  final ListType listType;
  final bool small;

  const ListTypeBadge({
    super.key,
    required this.listType,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconSize = small ? 12.0 : 14.0;
    final fontSize = small ? 10.0 : 12.0;
    final hPad = small ? 6.0 : 8.0;
    final vPad = small ? 2.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(listType.icon, size: iconSize, color: colors.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            listType.label,
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
