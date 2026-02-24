import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/lists.dart';
import '../../providers/auth.dart';
import './add_to_list_sheet.dart';

class AddToListButton extends StatelessWidget {
  final int productId;
  final bool compact;

  const AddToListButton({
    super.key,
    required this.productId,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ListsProvider>(
      builder: (context, listsProvider, _) {
        final auth = Provider.of<Auth>(context, listen: false);
        if (!auth.isSignedIn) return const SizedBox.shrink();

        final colors = Theme.of(context).colorScheme;
        final listsWithProduct = listsProvider.getListsContainingProduct(
          productId,
        );
        final count = listsWithProduct.length;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            AddToListSheet.show(context, productId);
          },
          child: Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              color: count > 0
                  ? colors.primaryContainer
                  : colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              count > 0 ? Icons.playlist_add_check : Icons.playlist_add,
              size: 16.r,
              color: count > 0
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
