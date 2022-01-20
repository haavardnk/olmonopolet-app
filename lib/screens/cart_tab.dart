import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_image/shimmer_image.dart';

import '../providers/cart.dart';

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
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Column(
                            children:
                                List.generate(cartData.itemCount, (index) {
                              return _buildItem(
                                  index,
                                  boxImageSize,
                                  cartData.items.values.elementAt(index),
                                  cartData,
                                  context);
                            }),
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
              color: Colors.white,
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
                  color: Color(0xFFe75f3f)),
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

  Column _buildItem(int index, double boxImageSize, CartItem cartItem,
      Cart cartData, BuildContext context) {
    int quantity = cartItem.quantity;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // Product detail page
              },
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: ProgressiveImage(
                    image: cartItem.imageUrl!,
                    height: boxImageSize,
                    width: boxImageSize,
                  )),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Product detail page
                    },
                    child: Text(
                      cartItem.name,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF515151)),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Kr ${cartItem.price}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showPopupDelete(index, boxImageSize, cartItem,
                                cartData, context);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            height: 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    width: 1, color: Colors.grey[300]!)),
                            child: const Icon(Icons.delete,
                                color: Color(0xff777777), size: 20),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                cartData.removeSingleItem(cartItem.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                height: 28,
                                decoration: BoxDecoration(
                                    color: Colors.cyan[600],
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.remove,
                                    color: Colors.white, size: 20),
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
                                cartData.addItem(
                                  cartItem.id,
                                  cartItem.name,
                                  cartItem.price,
                                  cartItem.imageUrl,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                height: 28,
                                decoration: BoxDecoration(
                                    color: Colors.cyan[600],
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 20),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        (index == cartData.itemCount - 1)
            ? Wrap()
            : Divider(
                height: 32,
                color: Colors.grey[400],
              )
      ],
    );
  }

  void showPopupDelete(int index, double boxImageSize, CartItem cartItem,
      Cart cartData, BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Nei', style: TextStyle(color: Color(0xff01aed6))));
    Widget continueButton = TextButton(
        onPressed: () {
          cartData.removeItem(cartItem.id);
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
        child: const Text('Ja', style: TextStyle(color: Color(0xff01aed6))));

    // set up the AlertDialog
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
          style: TextStyle(fontSize: 13, color: Color(0xff777777))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
