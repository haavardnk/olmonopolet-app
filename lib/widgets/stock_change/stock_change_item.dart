import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:flag/flag.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../models/stock_change.dart';
import '../../screens/product_detail_screen.dart';
import '../common/rating_widget.dart';
import '../common/item_popup_menu.dart';

class StockChangeItem extends StatefulWidget {
  const StockChangeItem({required this.stockChange, this.lastDate, super.key});

  final StockChange stockChange;
  final DateTime? lastDate;

  @override
  State<StockChangeItem> createState() => _StockChangeItemState();
}

class _StockChangeItemState extends State<StockChangeItem> {
  late bool wishlisted;

  @override
  void initState() {
    wishlisted = widget.stockChange.product.userWishlisted ?? false;
    initializeDateFormatting('nb_NO', null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData _mediaQueryData = MediaQuery.of(context);
    final _tabletMode = _mediaQueryData.size.shortestSide >= 600 ? true : false;
    final double _boxImageSize = _tabletMode
        ? 60 + _mediaQueryData.textScaleFactor * 10
        : _mediaQueryData.size.shortestSide / 5.9;
    final heroTag = 'stock${widget.stockChange.product.id}';
    late Offset tapPosition;
    RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    void getPosition(TapDownDetails detail) {
      tapPosition = detail.globalPosition;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.lastDate == null ||
            widget.lastDate!.day != widget.stockChange.stockUnstockAt!.day)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              toBeginningOfSentenceCase(DateFormat.yMMMMEEEEd('nb_NO')
                  .format(widget.stockChange.stockUnstockAt!)),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        if ((widget.lastDate == null ||
                widget.lastDate!.day ==
                    widget.stockChange.stockUnstockAt!.day) &&
            widget.lastDate != null)
          const Divider(
            height: 0,
          ),
        Container(
          foregroundDecoration: wishlisted == true
              ? const RotatedCornerDecoration.withColor(
                  color: Color(0xff01aed6),
                  badgeSize: Size(25, 25),
                )
              : null,
          child: Container(
            foregroundDecoration: widget.stockChange.product.userRating != null
                ? const RotatedCornerDecoration.withColor(
                    color: Color(0xFFFBC02D),
                    badgeSize: Size(25, 25),
                  )
                : null,
            child: Semantics(
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
                onTapDown: getPosition,
                onLongPress: () {
                  showPopupMenu(
                    context,
                    wishlisted,
                    tapPosition,
                    overlay,
                    widget.stockChange.product,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          child: Stack(
                            children: [
                              Hero(
                                tag: heroTag,
                                child: widget.stockChange.product.imageUrl !=
                                            null &&
                                        widget.stockChange.product.imageUrl!
                                            .isNotEmpty
                                    ? FancyShimmerImage(
                                        imageUrl: widget
                                            .stockChange.product.imageUrl!,
                                        height: _boxImageSize,
                                        width: _boxImageSize,
                                        errorWidget: Image.asset(
                                          'assets/images/placeholder.png',
                                          height: _boxImageSize,
                                          width: _boxImageSize,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        height: _boxImageSize,
                                        width: _boxImageSize,
                                      ),
                              ),
                              if (widget.stockChange.product.countryCode !=
                                      null &&
                                  widget.stockChange.product.countryCode!
                                      .isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(6)),
                                  child: Flag.fromString(
                                    widget.stockChange.product.countryCode!,
                                    height: 20,
                                    width: 20 * 4 / 3,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.stockChange.product.name,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Kr ${widget.stockChange.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' - Kr ${widget.stockChange.product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                )
                              ],
                            ),
                            Text(
                              widget.stockChange.product.style,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              child: widget.stockChange.product.userRating ==
                                      null
                                  ? Row(
                                      children: [
                                        Text(
                                          widget.stockChange.product.rating !=
                                                  null
                                              ? '${widget.stockChange.product.rating!.toStringAsFixed(2)} '
                                              : '0 ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        createRatingBar(
                                            rating: widget.stockChange.product
                                                        .rating !=
                                                    null
                                                ? widget
                                                    .stockChange.product.rating!
                                                : 0,
                                            size: 18,
                                            color: Colors.yellow[700]!),
                                        Text(
                                          widget.stockChange.product.checkins !=
                                                  null
                                              ? ' ${NumberFormat.compact().format(widget.stockChange.product.checkins)}'
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          widget.stockChange.product.rating !=
                                                  null
                                              ? 'Global: ${widget.stockChange.product.rating!.toStringAsFixed(2)}'
                                              : '0 ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow[700],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.stockChange.product
                                                      .userRating !=
                                                  null
                                              ? 'Din: ${widget.stockChange.product.userRating!.toStringAsFixed(2)} '
                                              : '0 ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow[700],
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: widget.stockChange.quantity > 0
                            ? Text(
                                '+${widget.stockChange.quantity}',
                                style: const TextStyle(
                                    fontSize: 22, color: Colors.green),
                              )
                            : const Icon(
                                Icons.close,
                                size: 34,
                                color: Colors.red,
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
