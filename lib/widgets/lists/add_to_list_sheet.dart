import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/user_list.dart';
import '../../providers/lists.dart';

class AddToListSheet extends StatelessWidget {
  final int productId;

  const AddToListSheet({super.key, required this.productId});

  static void show(BuildContext context, int productId) {
    final listsProvider = Provider.of<ListsProvider>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: listsProvider,
        child: AddToListSheet(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<ListsProvider>(
      builder: (ctx, provider, _) {
        final lists = provider.lists;

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Legg til i liste',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              if (lists.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      'Ingen lister ennå',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300.h),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: lists.length,
                      itemBuilder: (_, index) {
                        final list = lists[index];
                        final contains =
                            list.productIds.contains(productId.toString());

                        return _ListPickerItem(
                          list: list,
                          contains: contains,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            provider.toggleProductInList(
                              list.id,
                              productId,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ListPickerItem extends StatelessWidget {
  final UserList list;
  final bool contains;
  final VoidCallback onTap;

  const _ListPickerItem({
    required this.list,
    required this.contains,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        contains ? Icons.check_circle : Icons.circle_outlined,
        color: contains ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        list.name,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${list.itemCount} produkter · ${list.listType.label}',
        style: TextStyle(
          fontSize: 12.sp,
          color: colors.onSurfaceVariant,
        ),
      ),
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}
