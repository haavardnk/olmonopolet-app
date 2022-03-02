import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import '../../providers/filter.dart';
import '../products/multiselect.dart';

class BottomStoreSheet extends StatefulWidget {
  final Function initCartSettings;
  BottomStoreSheet(this.initCartSettings, {Key? key}) : super(key: key);

  @override
  _BottomStoreSheetState createState() => _BottomStoreSheetState();
}

class _BottomStoreSheetState extends State<BottomStoreSheet> {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
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
      icon: const Icon(Icons.store_outlined),
      label: const Text('Butikkvalg'),
    );
  }

  Widget _showPopup() {
    final cart = Provider.of<Cart>(context, listen: false);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
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
                    const Text('Butikkvalg for handleliste',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 4),
                      title: Text(
                          'Grå ut dersom ingen på lager i valgte butikker'),
                      value: cart.greyNoStock,
                      activeColor: Colors.pink,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.greyNoStock = value;
                          cart.saveCartSettings();
                          widget.initCartSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 4),
                      title:
                          Text('Skjul dersom ingen på lager i valgte butikker'),
                      value: cart.hideNoStock,
                      activeColor: Colors.pink,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.hideNoStock = value;
                          cart.saveCartSettings();
                          widget.initCartSettings();
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.only(left: 16, right: 4),
                      title: Text('Bruk butikkvalg fra oversikt'),
                      value: cart.useOverviewStoreSelection,
                      activeColor: Colors.pink,
                      onChanged: (bool value) {
                        mystate(() {
                          cart.useOverviewStoreSelection = value;
                          cart.saveCartSettings();
                          widget.initCartSettings();
                        });
                      },
                    ),
                    if (!cart.useOverviewStoreSelection)
                      FadeIn(
                        duration: Duration(milliseconds: 300),
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
                                if (!filters.storesLoading &&
                                    filters.storeList.isEmpty) {
                                  filters.getStores();
                                }
                                return filters.storeList.isNotEmpty
                                    ? DropDownMultiSelect(
                                        onChanged: (List<String> x) {
                                          mystate(() {
                                            cart.cartSelectedStores = x;
                                            cart.setCartStore(
                                                filters.storeList);
                                            widget.initCartSettings();
                                          });
                                        },
                                        options: filters.storeList
                                            .map((e) => e.name)
                                            .toList(),
                                        stores: filters.storeList,
                                        selectedValues: cart.cartSelectedStores,
                                        whenEmpty: 'Velg butikker',
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
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
