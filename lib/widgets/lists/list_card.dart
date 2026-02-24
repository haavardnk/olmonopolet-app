import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_list.dart';
import '../../utils/store_utils.dart';

class ListCard extends StatelessWidget {
  final UserList list;
  final int dragIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const ListCard({
    super.key,
    required this.list,
    required this.dragIndex,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPast = list.isPast == true;
    final storeName = list.listType == ListType.shopping
        ? lookupStoreName(context, list.selectedStoreId)
        : null;

    return Dismissible(
      key: Key('list-card-${list.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        onDelete();
        return false;
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.only(left: 50.w),
        child: const Row(
          children: [Icon(Icons.delete)],
        ),
      ),
      child: GestureDetector(
        onTap: () => context.go('/lists/${list.id}'),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Opacity(
            opacity: isPast ? 0.6 : 1.0,
            child: Padding(
              padding: EdgeInsets.only(
                left: 6.w,
                top: 12.h,
                bottom: 12.h,
                right: 4.w,
              ),
              child: Row(
                children: [
                  ReorderableDragStartListener(
                    index: dragIndex,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 20.r,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: isPast
                          ? colors.error.withValues(alpha: 0.12)
                          : colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      list.listType.icon,
                      size: 20.r,
                      color: isPast ? colors.error : colors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _buildSubtitle(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (storeName != null) ...[
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 12.r,
                                color: colors.onSurfaceVariant,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  storeName,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (list.description != null &&
                            list.description!.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            list.description!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: colors.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildBadge(colors),
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'share':
                          onShare();
                        case 'edit':
                          onEdit();
                        case 'delete':
                          onDelete();
                      }
                    },
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      size: 20.r,
                      color: colors.onSurfaceVariant,
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share_outlined, size: 18.r),
                            SizedBox(width: 8.w),
                            const Text('Del'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18.r),
                            SizedBox(width: 8.w),
                            const Text('Rediger'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18.r, color: colors.error),
                            SizedBox(width: 8.w),
                            Text('Slett',
                                style: TextStyle(color: colors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final count = '${list.itemCount} produkter';
    switch (list.listType) {
      case ListType.cellar:
        if (list.stats != null) {
          return '${list.stats!.totalBottles} flasker · Kr ${list.stats!.totalValue.toStringAsFixed(0)}';
        }
        return count;
      case ListType.event:
        if (list.eventDate != null) {
          final d = list.eventDate!;
          return '$count · ${d.day}. ${monthAbbreviations[d.month - 1]} ${d.year}';
        }
        return count;
      case ListType.shopping:
      case ListType.standard:
        return count;
    }
  }

  Widget _buildBadge(ColorScheme colors) {
    if (list.listType == ListType.shopping && list.totalPrice != null) {
      return _pill(
        'Kr ${list.totalPrice!.toStringAsFixed(0)}',
        colors.primary.withValues(alpha: 0.12),
        colors.primary,
      );
    }

    if (list.listType == ListType.event && list.isPast == true) {
      return _pill(
        'Passert',
        colors.error.withValues(alpha: 0.12),
        colors.error,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
