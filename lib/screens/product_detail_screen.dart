import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flag/flag.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';
import '../providers/filter.dart';
import '../providers/http_client.dart';
import '../services/api.dart';
import '../services/app_launcher.dart';
import '../models/product.dart';
import '../widgets/common/rating_widget.dart';
import '../widgets/common/stock_popup.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});
  static const routeName = '/product-detail';
  static final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _loadedProduct;
  List<StockInfo> _stockList = [];

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final product = args['product'] as Product;
    final herotag = args['herotag'] as String;
    final cart = Provider.of<Cart>(context, listen: false);
    final client = Provider.of<HttpClient>(context, listen: false);
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final tabletMode = 1.sw >= 600;
    final shortestSide = 1.sw < 1.sh ? 1.sw : 1.sh;
    final imageSize = shortestSide * (tabletMode ? 0.45 : 0.6);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_loadedProduct ?? product);
      },
      child: Scaffold(
        appBar: _buildAppBar(context, client.apiClient, product),
        floatingActionButton: _buildFab(context, cart, product),
        body: FutureBuilder<Product>(
          future: ApiHelper.getProductDetails(client.apiClient, product),
          builder: (context, snapshot) {
            final details = snapshot.data;
            if (details != null) {
              _loadedProduct = details;
              if (details.allStock != null && filters.storeList.isNotEmpty) {
                _stockList =
                    sortStockListByStores(details.allStock!, filters.storeList);
              }
            }
            final displayImageUrl =
                details?.labelHdUrl ?? product.labelHdUrl ?? product.imageUrl;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, product, details, herotag,
                      displayImageUrl, imageSize, colors),
                ),
                if (snapshot.hasError)
                  SliverFillRemaining(child: _buildError()),
                if (!snapshot.hasData && !snapshot.hasError)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (snapshot.hasData)
                  SliverToBoxAdapter(
                    child: FadeIn(
                      duration: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: tabletMode ? 0.15.sw : 0),
                        child: Column(
                          children: [
                            _buildRatingSection(context, product, colors),
                            _buildQuickStats(context, product, details, colors),
                            if (_hasFlavorProfile(details) ||
                                details?.valueScore != null)
                              _buildBarsSection(
                                  context, product, details!, colors),
                            _buildInfoSection(
                                context, product, details, colors),
                            _buildStockSection(context, product, colors),
                            if (details?.description != null &&
                                details!.description!.isNotEmpty)
                              _buildDescriptionSection(
                                  context, details.description!, colors),
                            SizedBox(height: 80.h),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, http.Client client, Product product) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(_loadedProduct ?? product),
      ),
      title: const Text('Detaljer'),
      actions: [
        PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 0,
              child: Row(
                children: [
                  const Icon(Icons.report_outlined),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      product.rating != null
                          ? 'Rapporter feil Untappd match'
                          : 'Foreslå untappd match',
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  const Icon(Icons.sports_bar_outlined),
                  SizedBox(width: 12.w),
                  const Text('Åpne i Untappd'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  const Icon(Icons.open_in_browser),
                  SizedBox(width: 12.w),
                  const Text('Åpne i Vinmonopolet'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 0) {
              _showWrongUntappdMatchSheet(context, client, product.id);
            } else if (value == 1) {
              AppLauncher.launchUntappd(product);
            } else if (value == 2 && product.vmpUrl != null) {
              launchUrl(Uri.parse(product.vmpUrl!));
            }
          },
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, Cart cart, Product product) {
    return Consumer<Cart>(
      builder: (context, _, __) {
        final inCart = cart.items.keys.contains(product.id);
        final quantity = inCart ? cart.items[product.id]!.quantity : 0;

        return GestureDetector(
          onLongPress: () {
            if (inCart) {
              HapticFeedback.mediumImpact();
              cart.removeSingleItem(product.id);
              cart.updateCartItemsData();
            }
          },
          child: FloatingActionButton.small(
            onPressed: () {
              HapticFeedback.lightImpact();
              cart.addItem(product.id, product);
              cart.updateCartItemsData();
            },
            child: Badge(
              isLabelVisible: inCart,
              label: Text('$quantity'),
              child: const Icon(Icons.add_shopping_cart),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context,
      Product product,
      Product? details,
      String herotag,
      String? displayImageUrl,
      double imageSize,
      ColorScheme colors) {
    // Calculate price per unit if alcohol units available
    double? pricePerUnit;
    if (details?.alcoholUnits != null && details!.alcoholUnits! > 0) {
      pricePerUnit = product.price / details.alcoholUnits!;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(0, 8.h, 0, 4.h),
      child: Column(
        children: [
          SizedBox(
            height: imageSize,
            width: double.infinity,
            child: Hero(
              tag: herotag,
              child: displayImageUrl != null && displayImageUrl.isNotEmpty
                  ? Image.network(displayImageUrl, fit: BoxFit.contain)
                  : Image.asset('assets/images/placeholder.png',
                      fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                Text(
                  product.name,
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kr ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    if (product.pricePerVolume != null) ...[
                      SizedBox(width: 6.w),
                      Text('·',
                          style: TextStyle(
                              fontSize: 14.sp, color: colors.onSurfaceVariant)),
                      SizedBox(width: 6.w),
                      Text(
                        '${product.pricePerVolume!.toStringAsFixed(0)} kr/l',
                        style: TextStyle(
                            fontSize: 13.sp, color: colors.onSurfaceVariant),
                      ),
                    ],
                    if (pricePerUnit != null) ...[
                      SizedBox(width: 6.w),
                      Text('·',
                          style: TextStyle(
                              fontSize: 14.sp, color: colors.onSurfaceVariant)),
                      SizedBox(width: 6.w),
                      Text(
                        '${pricePerUnit.toStringAsFixed(0)} kr/enhet',
                        style: TextStyle(
                            fontSize: 13.sp, color: colors.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  product.style,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(
      BuildContext context, Product product, ColorScheme colors) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: GestureDetector(
        onTap: () => AppLauncher.launchUntappd(product),
        child: product.rating != null
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.rating!.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: 24.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.w),
                      createRatingBar(
                          rating: product.rating!,
                          size: 20.r,
                          color: Colors.amber),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${NumberFormat.compact().format(product.checkins)} check-ins på Untappd',
                    style: TextStyle(
                        fontSize: 12.sp, color: colors.onSurfaceVariant),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline,
                      size: 16.r, color: colors.onSurfaceVariant),
                  SizedBox(width: 6.w),
                  Text(
                    'Ingen Untappd-match',
                    style: TextStyle(
                        fontSize: 13.sp, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
      ),
    );
  }

  bool _hasFlavorProfile(Product? details) {
    if (details == null) return false;
    return details.freshness != null ||
        details.bitterness != null ||
        details.sweetness != null ||
        details.fullness != null;
  }

  Widget _buildBarsSection(BuildContext context, Product product,
      Product details, ColorScheme colors) {
    final bars = <Widget>[];

    // Flavor profile bars
    if (details.freshness != null) {
      bars.add(_buildBar(
          'Friskhet', details.freshness! / 12, colors.primary, colors));
    }
    if (details.fullness != null) {
      bars.add(
          _buildBar('Fylde', details.fullness! / 12, colors.primary, colors));
    }
    if (details.bitterness != null) {
      bars.add(_buildBar(
          'Bitterhet', details.bitterness! / 12, colors.primary, colors));
    }
    if (details.sweetness != null && details.sweetness! > 0) {
      bars.add(
          _buildBar('Sødme', details.sweetness! / 12, colors.primary, colors));
    }

    // Value score bar
    if (details.valueScore != null) {
      Color valueColor;
      if (details.valueScore! >= 15) {
        valueColor = Colors.green;
      } else if (details.valueScore! >= 10) {
        valueColor = Colors.blue;
      } else if (details.valueScore! >= 5) {
        valueColor = Colors.orange;
      } else {
        valueColor = Colors.red;
      }
      bars.add(
          _buildBar('Verdi', details.valueScore! / 20, valueColor, colors));
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: bars,
      ),
    );
  }

  Widget _buildBar(
      String label, double value, Color barColor, ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6.h,
                backgroundColor: colors.outlineVariant.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                    barColor.withValues(alpha: 0.7)),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 35.w,
            child: Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, Product product,
      Product? details, ColorScheme colors) {
    final stats = <Widget>[];
    if (product.abv != null) {
      stats.add(_buildStat('Styrke', '${product.abv}%', colors));
    }
    stats.add(_buildStat('Størrelse', '${product.volume}L', colors));
    if (details?.acid != null) {
      stats.add(_buildStat('Syre', '${details!.acid} g/l', colors));
    }
    if (details?.sugar != null) {
      stats.add(_buildStat('Sukker', '${details!.sugar} g/l', colors));
    }
    if (details?.ibu != null && details!.ibu! > 0) {
      stats.add(_buildStat('IBU', details.ibu!.toStringAsFixed(0), colors));
    }
    if (details?.alcoholUnits != null && details!.alcoholUnits! > 0) {
      stats.add(_buildStat(
          'Enheter', details.alcoholUnits!.toStringAsFixed(1), colors));
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 8.h,
        alignment: WrapAlignment.center,
        children: stats,
      ),
    );
  }

  Widget _buildStat(String label, String value, ColorScheme colors) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
        Text(label,
            style: TextStyle(fontSize: 13.sp, color: colors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Product product,
      Product? details, ColorScheme colors) {
    final infoItems = <_InfoRow>[];

    // Primary info - what users care about most
    if (details?.taste != null) {
      infoItems.add(_InfoRow('Smak', _cleanText(details!.taste!)));
    }
    if (details?.aroma != null) {
      infoItems.add(_InfoRow('Lukt', _cleanText(details!.aroma!)));
    }
    if (details?.foodPairing != null) {
      infoItems.add(_InfoRow('Passer til', _cleanText(details!.foodPairing!)));
    }
    if (details?.brewery != null) {
      infoItems.add(_InfoRow('Bryggeri', details!.brewery!));
    }
    if (product.country != null) {
      infoItems.add(
          _InfoRow('Land', product.country!, countryCode: product.countryCode));
    }

    // Secondary info
    if (details?.year != null && details!.year! > 0) {
      infoItems.add(_InfoRow('Årgang', details.year.toString()));
    }
    if (details?.color != null) {
      infoItems.add(_InfoRow('Farge', _cleanText(details!.color!)));
    }
    if (details?.storable != null) {
      infoItems.add(_InfoRow('Lagring', _cleanText(details!.storable!)));
    }
    if (details?.rawMaterials != null) {
      infoItems.add(_InfoRow('Råstoff', _cleanText(details!.rawMaterials!)));
    }
    if (details?.method != null) {
      infoItems.add(_InfoRow('Metode', details!.method!));
    }

    // Technical info
    if (details?.allergens != null) {
      infoItems.add(_InfoRow('Allergen', details!.allergens!));
    }
    if (details?.productSelection != null) {
      infoItems.add(_InfoRow('Utvalg', details!.productSelection!));
    }
    infoItems.add(_InfoRow('Varenummer', product.id.toString()));

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasjon',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          ...infoItems.asMap().entries.map((entry) {
            final isLast = entry.key == infoItems.length - 1;
            return _buildInfoRow(entry.value, isLast, colors);
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoRow row, bool isLast, ColorScheme colors) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.w,
                child: Text(
                  row.label,
                  style: TextStyle(
                      fontSize: 13.sp, color: colors.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: row.countryCode != null
                    ? Row(
                        children: [
                          if (row.countryCode!.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2.r),
                              child: Flag.fromString(
                                row.countryCode!,
                                height: 12.r,
                                width: 16.r,
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Text(row.value, style: TextStyle(fontSize: 13.sp)),
                        ],
                      )
                    : Text(row.value, style: TextStyle(fontSize: 13.sp)),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: colors.outlineVariant),
      ],
    );
  }

  Widget _buildStockSection(
      BuildContext context, Product product, ColorScheme colors) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: GestureDetector(
        onTap: () => showStockPopup(
          context: context,
          productId: product.id,
          preloadedStock: _loadedProduct?.allStock,
        ),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Icon(Icons.store_outlined, size: 20.r, color: colors.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lagerstatus',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _stockList.isEmpty
                        ? 'Se tilgjengelighet i dine butikker'
                        : '${_stockList.length} ${_stockList.length == 1 ? 'butikk' : 'butikker'} har på lager',
                    style: TextStyle(
                        fontSize: 12.sp, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 24.r, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(
      BuildContext context, String description, ColorScheme colors) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Beskrivelse',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(description, style: TextStyle(fontSize: 13.sp, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.r),
          SizedBox(height: 16.h),
          const Text('Kunne ikke laste detaljer'),
        ],
      ),
    );
  }

  String _cleanText(String text) => text.replaceAll('.', '').trim();

  void _showWrongUntappdMatchSheet(
      BuildContext context, http.Client client, int productId) {
    final urlController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Form(
                key: ProductDetailScreen._formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Untappd link',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      autocorrect: false,
                      autofocus: true,
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vennligst skriv inn Untappd link';
                        }
                        if (!value.contains('https://untappd.com/b/') &&
                            !value.contains('https://untp.beer/')) {
                          return 'Ugyldig Untappd link';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                            'https://untappd.com/b/nogne-o-imperial-stout/42871',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _submitUntappdMatch(
                            context, client, productId, urlController.text),
                        icon: const Icon(Icons.send),
                        label: const Text('Send inn'),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitUntappdMatch(BuildContext context, http.Client client,
      int productId, String untappdUrl) async {
    if (!ProductDetailScreen._formKey.currentState!.validate()) return;
    if (untappdUrl.isEmpty) return;

    try {
      await ApiHelper.submitUntappdMatch(client, productId, untappdUrl);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Takk! Forslaget ditt er sendt inn.',
                textAlign: TextAlign.center),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kunne ikke sende forslag. Prøv igjen senere.',
                textAlign: TextAlign.center),
          ),
        );
      }
    }
  }
}

class _InfoRow {
  final String label;
  final String value;
  final String? countryCode;

  _InfoRow(this.label, this.value, {this.countryCode});
}
