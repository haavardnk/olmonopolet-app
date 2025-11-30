import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import '../../providers/filter.dart';
import '../../assets/constants.dart';
import '../filters/multi_select_dropdown.dart';

class CartBottomStoreSheet extends StatefulWidget {
  const CartBottomStoreSheet({super.key});

  @override
  BottomStoreSheetState createState() => BottomStoreSheetState();
}

class BottomStoreSheetState extends State<CartBottomStoreSheet> {
  late List<String?> _sortList;

  Future<void> initCartSettings() async {
    final cart = Provider.of<Cart>(context, listen: false);
    final filters = Provider.of<Filter>(context, listen: false);
    if (cart.useOverviewStoreSelection == true) {
      cart.cartStoreId = filters.storeId;
      cart.cartSelectedStores = filters.selectedStores.toList();
    }
    if (cart.cartStoreId.isNotEmpty && (cart.greyNoStock || cart.hideNoStock)) {
      cart.checkCartStockStatus();
    }
  }

  @override
  void initState() {
    _sortList = cartSortList;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet<void>(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          builder: (BuildContext context) {
            return _showPopup();
          },
        );
      },
      icon: const Icon(
        Icons.settings,
        semanticLabel: "Instillinger",
      ),
    );
  }

  Widget _showPopup() {
    final cart = Provider.of<Cart>(context, listen: false);
    return SizedBox(
      height: 0.6.sh,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter mystate) {
          return Column(
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
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    const Text('Sortering',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: SingleSelectDropdown<String>(
                        items: _sortList.whereType<String>().toList(),
                        selectedItem: cart.cartSortIndex,
                        itemLabel: (item) => item,
                        hintText: 'Velg sortering',
                        onChanged: (String? x) {
                          if (x != null) {
                            mystate(() {
                              cart.cartSortIndex = x;
                              cart.sortCart();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('Butikkvalg for handleliste',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.only(left: 16, right: 4),
                      title: const Text(
                          'Grå ut dersom ingen på lager i valgte butikker'),
                      value: cart.greyNoStock,
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.greyNoStock = value;
                          cart.saveCartSettings();
                          initCartSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.only(left: 16, right: 4),
                      title: const Text(
                          'Skjul dersom ingen på lager i valgte butikker'),
                      value: cart.hideNoStock,
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.hideNoStock = value;
                          cart.saveCartSettings();
                          initCartSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.only(left: 16, right: 4),
                      title: const Text('Bruk butikkvalg fra oversikt'),
                      value: cart.useOverviewStoreSelection,
                      activeThumbColor: Theme.of(context).colorScheme.primary,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.useOverviewStoreSelection = value;
                          cart.saveCartSettings();
                          initCartSettings();
                        });
                      },
                    ),
                    if (!cart.useOverviewStoreSelection)
                      FadeIn(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text('Butikk',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Consumer<Filter>(
                              builder: (context, filters, _) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                  child: MultiSelectDropdown<String>(
                                    items: filters.storeList
                                        .map((e) => e.name)
                                        .toList(),
                                    selectedItems: cart.cartSelectedStores,
                                    itemLabel: (item) => item,
                                    itemSubtitle: (item) {
                                      final store = filters.storeList
                                          .where((s) => s.name == item)
                                          .firstOrNull;
                                      if (store?.distance != null) {
                                        return '${store!.distance!.toStringAsFixed(0)} km';
                                      }
                                      return null;
                                    },
                                    hintText: 'Velg butikker',
                                    searchHint: 'Søk etter butikk...',
                                    selectedLabel: (selected) => selected
                                            .isEmpty
                                        ? 'Velg butikker'
                                        : selected.length == 1
                                            ? selected.first
                                            : '${selected.length} butikker valgt',
                                    asyncItems: () async {
                                      if (filters.storeList.isEmpty &&
                                          !filters.storesLoading) {
                                        await filters.getStores();
                                      }
                                      return filters.storeList
                                          .map((e) => e.name)
                                          .toList();
                                    },
                                    onChanged: (List<String> selected) {
                                      mystate(() {
                                        cart.cartSelectedStores = selected;
                                        cart.setCartStore(filters.storeList);
                                        initCartSettings();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
