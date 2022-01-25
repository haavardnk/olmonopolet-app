import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_image/shimmer_image.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:intl/intl.dart';

import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/products/rating_widget.dart';

class CartTab extends StatelessWidget {
  const CartTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    final double boxImageSize = (MediaQuery.of(context).size.width / 5);
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: cartData.itemCount > 0
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                          child: Column(
                            children: List.generate(
                              cartData.itemCount,
                              (index) {
                                return _buildItem(
                                    index,
                                    boxImageSize,
                                    cartData.items.values.elementAt(index),
                                    cartData,
                                    context);
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text('Handelisten er tom'),
                    ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).backgroundColor,
              child: Column(
                children: [
                  _createTotalPrice(cartData),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createTotalPrice(Cart cartData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Totalt',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(
              'Kr ${cartData.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) => Colors.pink,
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              )),
            ),
            onPressed: () {
              cartData.clear();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'TØM',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ))
      ],
    );
  }

  Container _buildItem(int index, double boxImageSize, CartItem cartItem,
      Cart cartData, BuildContext context) {
    int quantity = cartItem.quantity;
    return Container(
      child: Column(
        children: [
          Container(
            foregroundDecoration: cartItem.product.userRating != null
                ? const RotatedCornerDecoration(
                    color: Color(0xFFFBC02D),
                    geometry: BadgeGeometry(
                      width: 25,
                      height: 25,
                      cornerRadius: 0,
                      alignment: BadgeAlignment.topLeft,
                    ),
                  )
                : null,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ProductDetailScreen.routeName,
                      arguments: cartItem.product,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: Hero(
                      tag: cartItem.product.id,
                      child: cartItem.product.imageUrl != null
                          ? ProgressiveImage(
                              image: cartItem.product.imageUrl ?? '',
                              height: boxImageSize,
                              width: boxImageSize,
                              imageError: 'assets/images/placeholder.png',
                            )
                          : Image.asset(
                              'assets/images/placeholder.png',
                              height: boxImageSize,
                              width: boxImageSize,
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: boxImageSize,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ProductDetailScreen.routeName,
                              arguments: cartItem.product,
                            );
                          },
                          child: Text(
                            cartItem.product.name,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: Text(
                            'Kr ${cartItem.product.price}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: cartItem.product.userRating == null
                              ? Row(
                                  children: [
                                    Text(
                                      cartItem.product.rating != null
                                          ? '${cartItem.product.rating!.toStringAsFixed(2)} '
                                          : '0 ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    createRatingBar(
                                        rating: cartItem.product.rating != null
                                            ? cartItem.product.rating!
                                            : 0,
                                        size: 18),
                                    Text(
                                      cartItem.product.checkins != null
                                          ? ' ${NumberFormat.compact().format(cartItem.product.checkins)}'
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
                                      cartItem.product.rating != null
                                          ? 'Global: ${cartItem.product.rating!.toStringAsFixed(2)}'
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
                                      cartItem.product.userRating != null
                                          ? 'Din: ${cartItem.product.userRating!.toStringAsFixed(2)} '
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
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                    height: boxImageSize,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey[400]!,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            cartData.addItem(
                              cartItem.product.id,
                              cartItem.product,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            height: 28,
                            child: const Icon(Icons.add, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          quantity.toString(),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            quantity == 1
                                ? showPopupDelete(index, boxImageSize, cartItem,
                                    cartData, context)
                                : cartData
                                    .removeSingleItem(cartItem.product.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            height: 28,
                            child: const Icon(Icons.remove, size: 20),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
          (index == cartData.itemCount - 1)
              ? Wrap()
              : Divider(
                  height: 1,
                )
        ],
      ),
    );
  }

  void showPopupDelete(int index, double boxImageSize, CartItem cartItem,
      Cart cartData, BuildContext context) {
    Widget cancelButton = TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        'Nei',
        style: TextStyle(color: Colors.pink),
      ),
    );
    Widget continueButton = TextButton(
      onPressed: () {
        cartData.removeItem(cartItem.product.id);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Produktet har blitt fjernet fra handlelisten din.',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: const Text(
        'Ja',
        style: TextStyle(
          color: Colors.pink,
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'Fjern fra handleliste',
        style: TextStyle(fontSize: 18),
      ),
      content: const Text(
        'Er du sikker på at du vil fjerne dette produktet fra handlelisten?',
        style: TextStyle(
          fontSize: 13,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
