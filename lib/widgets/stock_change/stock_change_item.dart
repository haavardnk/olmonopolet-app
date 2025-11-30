import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flag/flag.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../models/stock_change.dart';
import '../../screens/product_detail_screen.dart';
import '../common/rating_widget.dart';

class StockChangeItem extends StatefulWidget {
  const StockChangeItem({required this.stockChange, this.lastDate, super.key});

  final StockChange stockChange;
  final DateTime? lastDate;

  @override
  State<StockChangeItem> createState() => _StockChangeItemState();
}

class _StockChangeItemState extends State<StockChangeItem> {
  @override
  void initState() {
    initializeDateFormatting('nb_NO', null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = 1.sw < 1.sh ? 1.sw : 1.sh;
    final tabletMode = shortestSide >= 600;
    final double boxImageSize = tabletMode ? 70.r : shortestSide / 5.9;
    final heroTag = 'stock${widget.stockChange.product.id}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.lastDate == null ||
            widget.lastDate!.day != widget.stockChange.stockUnstockAt!.day)
          Padding(
            padding: EdgeInsets.all(8.r),
            child: Text(
              toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO')
                  .format(widget.stockChange.stockUnstockAt!)),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
          ),
        if ((widget.lastDate == null ||
                widget.lastDate!.day ==
                    widget.stockChange.stockUnstockAt!.day) &&
            widget.lastDate != null)
          const Divider(
            height: 0,
          ),
        Semantics(
          label: widget.stockChange.product.name,
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              pushScreen(
                context,
                settings: RouteSettings(
                    name: ProductDetailScreen.routeName,
                    arguments: <String, dynamic>{
                      'product': widget.stockChange.product,
                      'herotag': heroTag,
                    }),
                screen: const ProductDetailScreen(),
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                withNavBar: true,
              );
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(6.r)),
                      child: Stack(
                        children: [
                          Hero(
                            tag: heroTag,
                            child: widget.stockChange.product.imageUrl !=
                                        null &&
                                    widget.stockChange.product.imageUrl!
                                        .isNotEmpty
                                ? FancyShimmerImage(
                                    imageUrl:
                                        widget.stockChange.product.imageUrl!,
                                    height: boxImageSize,
                                    width: boxImageSize,
                                    errorWidget: Image.asset(
                                      'assets/images/placeholder.png',
                                      height: boxImageSize,
                                      width: boxImageSize,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/placeholder.png',
                                    height: boxImageSize,
                                    width: boxImageSize,
                                  ),
                          ),
                          if (widget.stockChange.product.countryCode != null &&
                              widget
                                  .stockChange.product.countryCode!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(6.r)),
                              child: Flag.fromString(
                                widget.stockChange.product.countryCode!,
                                height: 20.r,
                                width: 20.r * 4 / 3,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stockChange.product.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              'Kr ${widget.stockChange.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ' - Kr ${widget.stockChange.product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                              style: TextStyle(
                                fontSize: 11.sp,
                              ),
                            )
                          ],
                        ),
                        Text(
                          widget.stockChange.product.style,
                          style: TextStyle(
                            fontSize: 12.sp,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.stockChange.product.rating != null
                                  ? '${widget.stockChange.product.rating!.toStringAsFixed(2)} '
                                  : '0 ',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                            createRatingBar(
                                rating:
                                    widget.stockChange.product.rating != null
                                        ? widget.stockChange.product.rating!
                                        : 0,
                                size: 18.r,
                                color: Colors.yellow[700]!),
                            Text(
                              widget.stockChange.product.checkins != null
                                  ? ' ${NumberFormat.compact().format(widget.stockChange.product.checkins)}'
                                  : '',
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: widget.stockChange.quantity > 0
                        ? Text(
                            '+${widget.stockChange.quantity}',
                            style:
                                TextStyle(fontSize: 22.sp, color: Colors.green),
                          )
                        : Icon(
                            Icons.close,
                            size: 34.r,
                            color: Colors.red,
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
