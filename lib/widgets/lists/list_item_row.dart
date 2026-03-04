import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flag/flag.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../models/user_list.dart';
import '../common/drag_handle.dart';
import '../common/rating_widget.dart';
import '../common/product_image.dart';
import '../common/info_chips.dart';

class ListItemRow extends StatelessWidget {
  final ListItem item;
  final Product? product;
  final ListType listType;
  final int? dragIndex;
  final bool? inStock;
  final int? stockCount;
  final VoidCallback onRemove;
  final void Function(int quantity)? onQuantityChanged;
  final void Function(int year)? onYearChanged;
  final void Function(String notes)? onNotesChanged;
  final String routePrefix;

  const ListItemRow({
    super.key,
    required this.item,
    this.product,
    required this.listType,
    this.dragIndex,
    this.inStock,
    this.stockCount,
    required this.onRemove,
    this.onQuantityChanged,
    this.onYearChanged,
    this.onNotesChanged,
    this.routePrefix = '/lists',
  });

  @override
  Widget build(BuildContext context) {
    final double imageSize = 70.r;
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('list-item-${item.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        onRemove();
        return false;
      },
      background: Container(
        color: Colors.pink,
        padding: EdgeInsets.only(left: 50.w),
        child: const Row(
          children: [Icon(Icons.delete)],
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: product != null
            ? () => context.push(
                  '/products/${product!.id}',
                  extra: product,
                )
            : null,
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dragIndex != null)
                        ReorderableDragStartListener(
                          index: dragIndex!,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.w, top: 2.h),
                            child: Icon(
                              Icons.drag_indicator,
                              size: 20.r,
                              color: colors.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      _buildImage(imageSize),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.name ?? 'Produkt #${item.productId}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (product != null) ...[
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  if (product!.countryCode != null &&
                                      product!.countryCode!.isNotEmpty) ...[
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(2.r),
                                      child: Flag.fromString(
                                        product!.countryCode!,
                                        height: 10.r,
                                        width: 10.r * 4 / 3,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                  ],
                                  Flexible(
                                    child: Text(
                                      product!.style,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  createRatingBar(
                                    rating: product!.rating ?? 0,
                                    size: 14.r,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    product!.rating?.toStringAsFixed(1) ?? '-',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  buildInfoChip(
                                    '${product!.volume}L',
                                    context,
                                    icon: Icons.water_drop_outlined,
                                  ),
                                  if (product!.abv != null) ...[
                                    SizedBox(width: 4.w),
                                    buildInfoChip(
                                      '${product!.abv!.toStringAsFixed(1)}%',
                                      context,
                                      icon: Icons.percent,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildRightColumn(colors),
                    ],
                  ),
                  if (listType == ListType.cellar) ...[
                    SizedBox(height: 8.h),
                    _buildVintageChip(context, colors),
                  ],
                  SizedBox(height: 8.h),
                  _buildNotesChip(context, colors),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildRightColumn(ColorScheme colors) {
    final isShopping = listType == ListType.shopping;
    final showQuantity = isShopping || listType == ListType.cellar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if ((isShopping || listType == ListType.cellar) &&
            product != null) ...[
          Text(
            '${(product!.price * item.quantity).toStringAsFixed(0)} kr',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (item.quantity > 1)
            Text(
              '${product!.price.toStringAsFixed(0)} × ${item.quantity}',
              style: TextStyle(
                fontSize: 11.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
          SizedBox(height: 6.h),
        ],
        if (showQuantity) _buildQuantityControl(colors),
        if (inStock != null && listType != ListType.cellar) ...[
          SizedBox(height: 4.h),
          _buildStockChip(colors),
        ],
      ],
    );
  }

  Widget _buildEditableChip({
    required BuildContext context,
    required ColorScheme colors,
    required IconData icon,
    required String text,
    required bool hasValue,
    required bool editable,
    required VoidCallback? onTap,
    int? maxLines,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14.r,
              color: hasValue ? colors.primary : colors.onSurfaceVariant,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: hasValue
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                ),
                maxLines: maxLines ?? 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (editable)
              Icon(
                Icons.chevron_right,
                size: 16.r,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVintageChip(BuildContext context, ColorScheme colors) {
    final hasYear = item.year != null;
    return _buildEditableChip(
      context: context,
      colors: colors,
      icon: Icons.calendar_today_outlined,
      text: hasYear ? 'Årgang ${item.year}' : 'Legg til årgang',
      hasValue: hasYear,
      editable: onYearChanged != null,
      onTap: onYearChanged != null
          ? () => _showYearSheet(context, colors)
          : null,
    );
  }

  Widget _buildNotesChip(BuildContext context, ColorScheme colors) {
    final hasNotes = item.notes != null && item.notes!.isNotEmpty;
    return _buildEditableChip(
      context: context,
      colors: colors,
      icon: hasNotes ? Icons.description_outlined : Icons.note_add_outlined,
      text: hasNotes ? item.notes! : 'Legg til notat',
      hasValue: hasNotes,
      editable: onNotesChanged != null,
      maxLines: 2,
      onTap: onNotesChanged != null
          ? () => _showNotesSheet(context, colors)
          : null,
    );
  }

  void _showEditSheet({
    required BuildContext context,
    required ColorScheme colors,
    required IconData icon,
    required String title,
    required String subtitle,
    required String hintText,
    required TextEditingController controller,
    required ValueChanged<String> onSave,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DragHandle(topMargin: true),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        icon,
                        color: colors.onPrimaryContainer,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: controller,
                      maxLines: maxLines,
                      keyboardType: keyboardType,
                      autofocus: true,
                      style: TextStyle(fontSize: 14.sp),
                      inputFormatters: inputFormatters,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 48.h,
                      child: FilledButton(
                        onPressed: () {
                          onSave(controller.text);
                          Navigator.pop(ctx);
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Lagre',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showYearSheet(BuildContext context, ColorScheme colors) {
    _showEditSheet(
      context: context,
      colors: colors,
      icon: Icons.calendar_today_outlined,
      title: 'Årgang',
      subtitle: 'Angi årgangen på produktet',
      hintText: 'F.eks. 2024',
      controller: TextEditingController(text: item.year?.toString() ?? ''),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onSave: (value) {
        final year = int.tryParse(value);
        if (year != null) onYearChanged?.call(year);
      },
    );
  }

  void _showNotesSheet(BuildContext context, ColorScheme colors) {
    _showEditSheet(
      context: context,
      colors: colors,
      icon: Icons.description_outlined,
      title: 'Notater',
      subtitle: 'Legg til et notat for dette produktet',
      hintText: 'Skriv et notat...',
      controller: TextEditingController(text: item.notes ?? ''),
      maxLines: 4,
      onSave: (value) => onNotesChanged?.call(value),
    );
  }

  Widget _buildStockChip(ColorScheme colors) {
    final hasStock = inStock == true;
    final label = hasStock
        ? '${stockCount ?? ''} stk'
        : 'Utsolgt';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: hasStock
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasStock ? Icons.check_circle : Icons.cancel,
            size: 12.r,
            color: hasStock ? Colors.green : Colors.red,
          ),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: hasStock ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(double size) {
    final imageUrl = product?.imageUrl;
    return ProductImage(imageUrl: imageUrl, size: size);
  }

  Widget _buildQuantityControl(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQtyButton(
            icon: Icons.remove,
            onTap: () {
              if (item.quantity > 1 && onQuantityChanged != null) {
                onQuantityChanged!(item.quantity - 1);
              }
            },
            colors: colors,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildQtyButton(
            icon: Icons.add,
            onTap: () {
              if (onQuantityChanged != null) {
                onQuantityChanged!(item.quantity + 1);
              }
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(icon, size: 16.r, color: colors.onSurface),
      ),
    );
  }
}
