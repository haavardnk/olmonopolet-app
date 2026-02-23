import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';

import '../../models/product.dart';
import '../../models/stock_change.dart';
import '../common/rating_widget.dart';
import '../common/info_chips.dart';
import '../common/tasted_badge.dart';

class StockChangeItem extends StatefulWidget {
  const StockChangeItem({required this.stockChange, this.lastDate, super.key});

  final StockChange stockChange;
  final DateTime? lastDate;

  @override
  State<StockChangeItem> createState() => _StockChangeItemState();
}

class _StockChangeItemState extends State<StockChangeItem> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('nb_NO', null);
    _product = widget.stockChange.product;
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final double imageSize = 85.r;
    final displayImageUrl = product.labelHdUrl ?? product.imageUrl;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.lastDate == null ||
            widget.lastDate!.day != widget.stockChange.stockUnstockAt!.day)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Text(
              toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO')
                  .format(widget.stockChange.stockUnstockAt!)),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
        Semantics(
          label: product.name,
          button: true,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: InkWell(
              onTap: () async {
                final result = await context.push<Product>(
                  '/stock/${product.id}',
                  extra: product,
                );
                if (result != null) {
                  setState(() {
                    _product = result;
                  });
                }
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: displayImageUrl != null &&
                                      displayImageUrl.isNotEmpty
                                  ? FancyShimmerImage(
                                      imageUrl: displayImageUrl,
                                      height: imageSize,
                                      width: imageSize,
                                      boxFit: BoxFit.cover,
                                      errorWidget: Image.asset(
                                        'assets/images/placeholder.png',
                                        height: imageSize,
                                        width: imageSize,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/placeholder.png',
                                      height: imageSize,
                                      width: imageSize,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                        TastedBadge(
                          product: _product,
                          onToggled: (updated) => setState(() => _product = updated),
                        ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: _buildStockBadge(),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Kr ${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      height: 1.0,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    '·',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    '${product.pricePerVolume!.toStringAsFixed(0)} kr/l',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  if (product.isChristmasBeer) ...[
                                    buildChristmasChip(context),
                                    SizedBox(width: 6.w),
                                  ],
                                  Expanded(
                                    child: Text(
                                      product.style,
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
                                      rating: product.rating ?? 0,
                                      size: 16.r,
                                      color: Colors.amber),
                                  SizedBox(width: 4.w),
                                  Text(
                                    product.rating?.toStringAsFixed(1) ?? '-',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (product.checkins != null) ...[
                                    SizedBox(width: 4.w),
                                    Text(
                                      '(${NumberFormat.compact().format(product.checkins)})',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 4.h,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  buildInfoChip('${product.volume}L', context,
                                      icon: Icons.water_drop_outlined),
                                  if (product.abv != null)
                                    buildInfoChip(
                                        '${product.abv!.toStringAsFixed(1)}%',
                                        context,
                                        icon: Icons.percent),
                                  if (product.country != null &&
                                      product.country!.isNotEmpty)
                                    buildInfoChipWithFlag(
                                      product.country!,
                                      product.countryCode,
                                      context,
                                    ),
                                ],
                              ),
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
      ],
    );
  }

  Widget _buildStockBadge() {
    final isPositive = widget.stockChange.quantity > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.withValues(alpha: 0.9)
            : Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          bottomRight: Radius.circular(8.r),
        ),
      ),
      child: isPositive
          ? Text(
              '+${widget.stockChange.quantity}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : Icon(
              Icons.close,
              size: 14.r,
              color: Colors.white,
            ),
    );
  }
}
