import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../helpers/api_helper.dart';
import '../models/product.dart';
import '../widgets/products/rating_widget.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final apiToken = Provider.of<Auth>(context, listen: false).token;
    final cart = Provider.of<Cart>(context, listen: false);
    final _boxImageSize = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            product.name,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      body: FutureBuilder(
        future: ApiHelper.getDetailedProductInfo(product.id, apiToken),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) =>
            Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    foregroundDecoration: product.userRating != null
                        ? const RotatedCornerDecoration(
                            color: Color(0xff00acc1),
                            textSpan: TextSpan(text: 'Smakt'),
                            geometry: BadgeGeometry(
                              width: 60,
                              height: 60,
                              cornerRadius: 0,
                              alignment: BadgeAlignment.topLeft,
                            ),
                          )
                        : null,
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 5),
                    height: _boxImageSize,
                    width: _boxImageSize,
                    child:
                        snapshot.hasData && snapshot.data!['label_hd_url'] != ''
                            ? FadeInImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(
                                  snapshot.data!['label_hd_url'],
                                ),
                                placeholder: product.imageUrl != null
                                    ? NetworkImage(product.imageUrl!)
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.contain,
                                      ).image,
                              )
                            : Hero(
                                tag: product.id,
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
                                        fit: BoxFit.contain,
                                      )
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.contain,
                                      ),
                              ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Kr ${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(product.style,
                            style: const TextStyle(
                              fontSize: 14,
                            )),
                        const SizedBox(height: 12),
                        if (product.rating != null)
                          product.userRating == null
                              ? Row(
                                  children: [
                                    Text(
                                      product.rating != null
                                          ? '${product.rating!.toStringAsFixed(2)} '
                                          : '0 ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    createRatingBar(
                                        rating: product.rating != null
                                            ? product.rating!
                                            : 0,
                                        size: 18),
                                    Text(
                                      product.checkins != null
                                          ? ' ${NumberFormat.compact().format(product.checkins)}'
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFaaaaaa)),
                                    ),
                                  ],
                                )
                              : IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Global rating: ',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            product.userRating != null
                                                ? '${product.rating!.toStringAsFixed(2)} '
                                                : '0 ',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow[700],
                                            size: 18,
                                          ),
                                          Text(
                                            ' ${NumberFormat.compact().format(product.checkins)}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFFaaaaaa)),
                                          ),
                                        ],
                                      ),
                                      VerticalDivider(
                                        width: 30,
                                        thickness: 1,
                                        color: Colors.grey[300],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Din rating: ',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            product.userRating != null
                                                ? '${product.userRating!.toStringAsFixed(2)} '
                                                : '0 ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow[700],
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                        if (product.rating == null)
                          const Text(
                            'Ingen Untappd Match',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(
                          height: 9,
                        ),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              if (product.stock != null && product.stock != 0)
                                Row(
                                  children: [
                                    Text(
                                      'På lager: ${product.stock}%',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xff777777),
                                      ),
                                    ),
                                    VerticalDivider(
                                      width: 30,
                                      thickness: 1,
                                      color: Colors.grey[300],
                                    ),
                                  ],
                                ),
                              Text(
                                product.abv != null
                                    ? 'Styrke: ${product.abv}%'
                                    : '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff777777),
                                ),
                              ),
                              if (product.abv != null)
                                VerticalDivider(
                                  width: 30,
                                  thickness: 1,
                                  color: Colors.grey[300],
                                ),
                              Text(
                                'Størrelse: ${product.volume}cl',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff777777),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Informasjon',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Bryggeri',
                                  style: TextStyle(color: Color(0xff777777))),
                              SizedBox(
                                width: 250,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      snapshot.hasData &&
                                              snapshot.data!['brewery'] != null
                                          ? snapshot.data!['brewery']
                                          : '',
                                      style: const TextStyle(
                                          color: Color(0xff777777))),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ibu',
                                  style: TextStyle(color: Color(0xff777777))),
                              SizedBox(
                                width: 250,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      snapshot.hasData &&
                                              snapshot.data!['ibu'] != null
                                          ? snapshot.data!['ibu'].toString()
                                          : '',
                                      style: const TextStyle(
                                          color: Color(0xff777777))),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Land',
                                  style: TextStyle(color: Color(0xff777777))),
                              Text(
                                  snapshot.hasData
                                      ? snapshot.data!['country']
                                      : '',
                                  style:
                                      const TextStyle(color: Color(0xff777777)))
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Utvalg',
                                  style: TextStyle(color: Color(0xff777777))),
                              Text(
                                  snapshot.hasData
                                      ? snapshot.data!['product_selection']
                                      : '',
                                  style: const TextStyle(
                                      color: Color(0xff777777))),
                            ],
                          ),
                        ],
                      )),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Beskrivelse',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 16,
                        ),
                        if (snapshot.hasData &&
                            snapshot.data!['description'] != null)
                          Text(snapshot.data!['description']),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      label: Text(product.rating != null
                          ? 'Rapporter feil Untappd match'
                          : 'Foreslå untappd match'),
                      icon: const Icon(Icons.report),
                    ),
                  ),
                  if (product.rating != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          snapshot.hasData &&
                                  snapshot.data!['untpd_url'] != null
                              ? _launchInBrowser(snapshot.data!['untpd_url'])
                              : null;
                        },
                        label: const Text('Untappd.com'),
                        icon: const Icon(Icons.open_in_browser),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        snapshot.hasData && snapshot.data!['vmp_url'] != null
                            ? _launchInBrowser(snapshot.data!['vmp_url'])
                            : null;
                      },
                      label: const Text('Vinmonopolet.no'),
                      icon: const Icon(Icons.open_in_browser),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 2.0,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  cart.addItem(product.id, product.name, product.price,
                      product.imageUrl);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Lagt til i handlevogn!',
                        textAlign: TextAlign.center,
                      ),
                      duration: const Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'ANGRE',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      width: 1,
                      color: Colors.pink,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Legg til i handleliste',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchInBrowser(String url) async {
  if (!await launch(
    url,
    forceSafariVC: false,
    forceWebView: false,
    headers: <String, String>{'my_header_key': 'my_header_value'},
  )) {
    throw 'Could not launch $url';
  }
}
