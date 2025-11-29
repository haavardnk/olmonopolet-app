import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flag/flag.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';
import '../providers/filter.dart';
import '../providers/http_client.dart';
import '../services/api.dart';
import '../services/app_launcher.dart';
import '../models/product.dart';
import '../widgets/common/rating_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});
  static const routeName = '/product-detail';
  static final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool wishlisted;
  late bool init = false;

  List<StockInfo> _stockList = [];
  List<StockInfo> _sortStockList(List<StockInfo> stockList, List storeList) {
    final storeNames = storeList.map((e) => e.name).toList();
    Map<String, int> order = {
      for (var key in storeNames) key: storeNames.indexOf(key)
    };
    final filteredList =
        stockList.where((s) => order.containsKey(s.storeName)).toList();
    filteredList
        .sort((a, b) => order[a.storeName]!.compareTo(order[b.storeName]!));
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final product = args['product'] as Product;
    final herotag = args['herotag'] as String;
    final cart = Provider.of<Cart>(context, listen: false);
    final client = Provider.of<HttpClient>(context, listen: false);
    final filters = Provider.of<Filter>(context, listen: false);
    final mediaQueryData = MediaQuery.of(context);
    final tabletMode = mediaQueryData.size.width >= 600 ? true : false;
    final boxImageSize =
        mediaQueryData.size.shortestSide * (tabletMode ? 0.4 : 0.75);

    if (init == false) {
      wishlisted = false;
      init = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detaljer'),
        surfaceTintColor: Colors.transparent,
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    children: [
                      const Icon(Icons.report),
                      const VerticalDivider(width: 5),
                      Text(
                        product.rating != null
                            ? 'Rapporter feil Untappd match'
                            : 'Foreslå untappd match',
                        overflow: TextOverflow.fade,
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    children: [
                      Icon(Icons.open_in_browser),
                      VerticalDivider(width: 5),
                      Text("Åpne i Untappd"),
                    ],
                  ),
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    children: [
                      Icon(Icons.open_in_browser),
                      VerticalDivider(width: 5),
                      Text("Åpne i Vinmonopolet"),
                    ],
                  ),
                ),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              wrongUntappdMatch(client.apiClient, product);
            } else if (value == 1) {
              AppLauncher.launchUntappd(product);
            } else if (value == 2) {
              product.vmpUrl != null
                  ? launchUrl(Uri.parse(product.vmpUrl!))
                  : null;
            }
          }),
        ],
      ),
      floatingActionButton: InkWell(
        onLongPress: () {
          if (cart.items.keys.contains(product.id)) {
            cart.removeSingleItem(product.id);
            cart.updateCartItemsData();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  cart.items.keys.contains(product.id)
                      ? 'Fjernet en fra handlelisten!'
                      : 'Fjernet helt fra handlelisten!',
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: FloatingActionButton(
          child: Consumer<Cart>(
            builder: (context, _, __) => Badge(
              isLabelVisible: cart.items.keys.contains(product.id),
              label: Text(cart.items.keys.contains(product.id)
                  ? cart.items[product.id]!.quantity.toString()
                  : ''),
              child: const Icon(Icons.add_shopping_cart),
            ),
          ),
          onPressed: () {
            cart.addItem(product.id, product);
            cart.updateCartItemsData();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Lagt til i handlelisten!',
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'ANGRE',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<Product>(
        future: ApiHelper.getProductDetails(client.apiClient, product),
        builder: (context, snapshot) {
          final details = snapshot.data;
          if (details != null &&
              details.allStock != null &&
              filters.storeList.isNotEmpty) {
            _stockList = _sortStockList(details.allStock!, filters.storeList);
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: tabletMode &&
                          mediaQueryData.orientation == Orientation.landscape
                      ? EdgeInsets.symmetric(
                          horizontal: mediaQueryData.size.width * 0.15)
                      : null,
                  children: [
                    Container(
                      foregroundDecoration: wishlisted == true
                          ? const RotatedCornerDecoration.withColor(
                              color: Color(0xff01aed6),
                              textSpan: TextSpan(text: 'Ønsket'),
                              badgeSize: Size(60, 60),
                              badgePosition: BadgePosition.topEnd,
                            )
                          : null,
                      child: SizedBox(
                        height: boxImageSize,
                        width: boxImageSize,
                        child: details != null &&
                                details.labelHdUrl != null &&
                                details.labelHdUrl!.isNotEmpty
                            ? FadeInImage(
                                fit: BoxFit.contain,
                                image: NetworkImage(
                                  details.labelHdUrl!,
                                ),
                                placeholder: product.imageUrl != null
                                    ? NetworkImage(product.imageUrl!)
                                    : Image.asset(
                                        'assets/images/placeholder.png',
                                        fit: BoxFit.contain,
                                      ).image,
                              )
                            : Hero(
                                tag: herotag,
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
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 18),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'Kr ${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (product.pricePerVolume != null)
                                Text(
                                  ' - Kr ${product.pricePerVolume!.toStringAsFixed(2)} pr. liter',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                )
                            ],
                          ),
                          Text(
                            product.style,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const Divider(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    if (snapshot.hasError)
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 8,
                          ),
                          Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                    'Kunne ikke laste detaljer: ${snapshot.error}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (!snapshot.hasData && !snapshot.hasError)
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 8,
                          ),
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    if (snapshot.hasData)
                      FadeIn(
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (product.rating != null)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 0, 20, 0),
                                          child: IntrinsicHeight(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: tabletMode
                                                      ? MainAxisAlignment
                                                          .spaceEvenly
                                                      : MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () => AppLauncher
                                                          .launchUntappd(
                                                              product),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Global rating - ${NumberFormat.compact().format(product.checkins)}',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        14),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                product.rating !=
                                                                        null
                                                                    ? '${product.rating!.toStringAsFixed(2)} '
                                                                    : '0 ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              createRatingBar(
                                                                  rating: product
                                                                              .rating !=
                                                                          null
                                                                      ? product
                                                                          .rating!
                                                                      : 0,
                                                                  size: 18,
                                                                  color: Colors
                                                                          .yellow[
                                                                      700]!),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
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
                                      if (details != null &&
                                          (details.freshness != null ||
                                              details.bitterness != null ||
                                              details.sweetness != null ||
                                              details.fullness != null))
                                        const Divider(
                                          height: 20,
                                        ),
                                      if (details != null &&
                                          (details.freshness != null ||
                                              details.bitterness != null ||
                                              details.sweetness != null ||
                                              details.fullness != null))
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (details.freshness != null)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: details.freshness!
                                                        .toDouble() /
                                                    12,
                                                center: Text((details
                                                                .freshness! /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Friskhet",
                                                ),
                                              ),
                                            if (details.fullness != null)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: details.fullness!
                                                        .toDouble() /
                                                    12,
                                                center: Text((details
                                                                .fullness! /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Fylde",
                                                ),
                                              ),
                                            if (details.bitterness != null)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: details.bitterness!
                                                        .toDouble() /
                                                    12,
                                                center: Text((details
                                                                .bitterness! /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Bitterhet",
                                                ),
                                              ),
                                            if (details.sweetness != null &&
                                                details.sweetness != 0)
                                              CircularPercentIndicator(
                                                radius: 25.0,
                                                lineWidth: 5.0,
                                                animation: true,
                                                percent: details.sweetness!
                                                        .toDouble() /
                                                    12,
                                                center: Text((details
                                                                .sweetness! /
                                                            12 *
                                                            100)
                                                        .toStringAsFixed(0) +
                                                    '%'),
                                                backgroundColor: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                progressColor: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                footer: const Text(
                                                  "Sødme",
                                                ),
                                              )
                                          ],
                                        ),
                                      const Divider(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          if (product.abv != null)
                                            Column(
                                              children: [
                                                const Text('Styrke'),
                                                Text('${product.abv} %'),
                                              ],
                                            ),
                                          Column(
                                            children: [
                                              const Text('Størrelse'),
                                              Text('${product.volume} l'),
                                            ],
                                          ),
                                          if (details != null &&
                                              details.acid != null)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('Syre'),
                                                  Text('${details.acid} g/l'),
                                                ],
                                              ),
                                            ),
                                          if (details != null &&
                                              details.sugar != null)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('Sukker'),
                                                  Text('${details.sugar} g/l'),
                                                ],
                                              ),
                                            ),
                                          if (details != null &&
                                              details.ibu != null &&
                                              details.ibu != 0)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('IBU'),
                                                  Text(
                                                    details.ibu.toString(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (details != null &&
                                              details.alcoholUnits != null &&
                                              details.alcoholUnits != 0)
                                            FadeIn(
                                              child: Column(
                                                children: [
                                                  const Text('Alkoholenheter'),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        details.alcoholUnits!
                                                            .toStringAsFixed(1),
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
                              ],
                            ),
                            const Divider(
                              height: 15,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informasjon',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (details != null &&
                                      details.year != null &&
                                      details.year != 0)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Årgang'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.year.toString(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null &&
                                      details.year != null &&
                                      details.year != 0)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null && details.taste != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Smak'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.taste!
                                                  .replaceAll(".", ""),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null && details.taste != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null && details.aroma != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Lukt'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.aroma!
                                                  .replaceAll(".", ""),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null && details.aroma != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null && details.color != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Farge'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.color!
                                                  .replaceAll(".", ""),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null && details.color != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null &&
                                      details.foodPairing != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Passer til'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.foodPairing!
                                                  .replaceAll(".", ""),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null &&
                                      details.foodPairing != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null &&
                                      details.storable != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Lagring'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.storable!
                                                  .toString()
                                                  .replaceAll(".", ""),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null &&
                                      details.storable != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null &&
                                      details.rawMaterials != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Råstoff'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.rawMaterials!
                                                  .toString()
                                                  .replaceAll(".", ""),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null &&
                                      details.rawMaterials != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null && details.method != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Metode'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.method!.toString(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null && details.method != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null &&
                                      details.allergens != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Allergen'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.allergens!.toString(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (details != null &&
                                      details.allergens != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (details != null &&
                                      details.brewery != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Bryggeri'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.brewery!,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (details != null &&
                                      details.brewery != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  if (product.country != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Land'),
                                          ),
                                          Flexible(
                                            child: Row(
                                              children: [
                                                Text(
                                                  product.country!,
                                                ),
                                                if (product.countryCode !=
                                                        null &&
                                                    product.countryCode!
                                                        .isNotEmpty)
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 3,
                                                      ),
                                                      Flag.fromString(
                                                        product.countryCode!,
                                                        height: 12,
                                                        width: 12 * 4 / 3,
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (product.country != null)
                                    const Divider(
                                      height: 8,
                                    ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 115,
                                        child: Text('Varenummer'),
                                      ),
                                      Flexible(
                                        child: Text(
                                          product.id.toString(),
                                        ),
                                      )
                                    ],
                                  ),
                                  const Divider(
                                    height: 8,
                                  ),
                                  if (details != null &&
                                      details.productSelection != null)
                                    FadeIn(
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 115,
                                            child: Text('Utvalg'),
                                          ),
                                          Flexible(
                                            child: Text(
                                              details.productSelection!,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Divider(
                              height: 15,
                            ),
                            ExpansionTile(
                              title:
                                  const Text("Vis butikker med varen på lager",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      )),
                              dense: true,
                              shape: const Border(),
                              children: [
                                Container(
                                  height: _stockList.length < 6
                                      ? _stockList.length * 15 + 65
                                      : 165,
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      if (_stockList.isNotEmpty)
                                        Expanded(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: _stockList.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(_stockList[index]
                                                          .storeName),
                                                      Text(
                                                        'På lager: ${_stockList[index].quantity}',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                  if (index <
                                                      _stockList.length - 1)
                                                    const Divider(
                                                      height: 5,
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      if (_stockList.isEmpty)
                                        const Text(
                                          'Ingen butikker har denne varen på lager',
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 20,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Beskrivelse',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (details != null &&
                                      details.description != null)
                                    Text(details.description!),
                                  if (details != null &&
                                      details.description == '')
                                    const Center(
                                      child: Text(
                                        'Mangler beskrivelse',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _showWrongUntappdMatchPopup(
      BuildContext context, client, int productId) {
    final urlController = TextEditingController();

    Future<void> showDialogMessage(String title, String message) async {
      Widget continueButton = FilledButton.tonal(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        child: const Text(
          'OK',
        ),
      );

      AlertDialog alert = AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          continueButton,
        ],
      );

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    void submit() async {
      if (!ProductDetailScreen._formKey.currentState!.validate()) {
        return;
      }
      if (urlController.text.isEmpty) {
        return;
      }
      final untappdUrl = urlController.text;
      try {
        await ApiHelper.submitUntappdMatch(client, productId, untappdUrl);
        await showDialogMessage('Takk for hjelpen!',
            'Ditt forslag er nå sendt inn og vil bli behandlet innen kort tid.');
      } catch (error) {
        await showDialogMessage(
            'Det oppsto en feil',
            'Det oppsto en feil når vi forsøkte å sende forslaget ditt. '
                'Sjekk at linken er en korrekt untappd link eller prøv igjen senere.');
      }
      Navigator.of(context).pop();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.27 +
          MediaQuery.of(context).viewInsets.bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Flexible(
            child: Form(
              key: ProductDetailScreen._formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  const Text('Untappd link',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autocorrect: false,
                    autofocus: true,
                    controller: urlController,
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vennligst skriv inn riktig Untappd link.';
                      }
                      if (!value.contains('https://untappd.com/b/') &&
                          !value.contains('https://untp.beer/')) {
                        return 'Ugyldig untappd link.';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'https://untappd.com/b/nogne-o-imperial-stout/42871',
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      submit();
                    },
                    label: const Text('Send inn'),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showFriendsCheckinsPopup(BuildContext context, List<dynamic> checkins,
      MediaQueryData mediaQueryData) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[500],
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            height: mediaQueryData.size.height * 0.4 - 28,
            width: mediaQueryData.size.width,
            child: ListView.builder(
                itemCount: checkins.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                foregroundImage:
                                    NetworkImage(checkins[index]['avatar']),
                                backgroundImage: const AssetImage(
                                    'assets/images/default_avatar.png'),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                checkins[index]['username'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${checkins[index]['rating'].toStringAsFixed(2)} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              createRatingBar(
                                  rating: checkins[index]['rating'],
                                  size: 18,
                                  color: Colors.yellow[700]!),
                              Text(
                                ' (${checkins[index]['count']})',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Divider(
                        height: 10,
                      )
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }

  wrongUntappdMatch(http.Client client, Product product) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return _showWrongUntappdMatchPopup(context, client, product.id);
      },
    );
  }

  friendsCheckins(List<dynamic> checkins, MediaQueryData mediaQueryData) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return _showFriendsCheckinsPopup(context, checkins, mediaQueryData);
      },
    );
  }
}
