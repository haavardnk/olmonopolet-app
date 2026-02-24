import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../../models/release.dart';
import '../../widgets/lists/add_to_list_button.dart';
import '../common/product_action_menu.dart';
import '../common/product_image.dart';
import '../common/rating_widget.dart';
import '../common/info_chips.dart';
import '../common/tasted_badge.dart';
import '../../assets/constants.dart';

class ProductItem extends StatefulWidget {
  const ProductItem({required this.product, super.key, this.release});

  final Product product;
  final Release? release;

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize = 85.r;
    final displayImageUrl = _product.labelHdUrl ?? _product.imageUrl;

    return Semantics(
      label: _product.name,
      button: true,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: InkWell(
          onTap: () async {
            final basePath = widget.release != null
                ? '/releases/${widget.release!.name.replaceAll(' ', '-')}'
                : '/products';
            final result = await context.push<Product>(
              '$basePath/${_product.id}',
              extra: _product,
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
                  _product.name,
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
                    ProductImage(
                      imageUrl: displayImageUrl,
                      size: imageSize,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Kr ${_product.price.toStringAsFixed(2)}',
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${_product.pricePerVolume!.toStringAsFixed(0)} kr/l',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              if (_product.pricePerAlcoholUnit != null) ...[
                                SizedBox(width: 6.w),
                                Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '${_product.pricePerAlcoholUnit!.toStringAsFixed(0)} kr/AE',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              if (_product.isChristmasBeer) ...[
                                buildChristmasChip(context),
                                SizedBox(width: 6.w),
                              ],
                              Expanded(
                                child: Text(
                                  _product.style,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                                  rating: _product.rating ?? 0,
                                  size: 16.r,
                                  color: Colors.amber),
                              SizedBox(width: 4.w),
                              Text(
                                _product.rating?.toStringAsFixed(1) ?? '-',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_product.checkins != null) ...[
                                SizedBox(width: 4.w),
                                Text(
                                  '(${NumberFormat.compact().format(_product.checkins)})',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
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
                              buildInfoChip('${_product.volume}L', context,
                                  icon: Icons.water_drop_outlined),
                              if (_product.abv != null)
                                buildInfoChip(
                                    '${_product.abv!.toStringAsFixed(1)}%',
                                    context,
                                    icon: Icons.percent),
                              if (_product.country != null &&
                                  _product.country!.isNotEmpty)
                                buildInfoChipWithFlag(
                                  _product.country!,
                                  _product.countryCode,
                                  context,
                                ),
                              if (widget.release != null &&
                                  widget.release!.productSelections.length > 1)
                                buildInfoChip(
                                    productSelectionAbbreviationList[
                                            _product.productSelection] ??
                                        '',
                                    context),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TastedBadge(
                          product: _product,
                          onToggled: (updated) =>
                              setState(() => _product = updated),
                        ),
                        SizedBox(height: 4.h),
                        AddToListButton(productId: _product.id),
                        SizedBox(height: 4.h),
                        ProductActionMenu(
                          product: _product,
                          compact: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
