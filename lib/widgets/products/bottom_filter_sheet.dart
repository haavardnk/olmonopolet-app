import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import '../../providers/auth.dart';
import 'multiselect_stores.dart';

class BottomFilterSheet extends StatefulWidget {
  const BottomFilterSheet({Key? key}) : super(key: key);

  @override
  _BottomFilterSheetState createState() => _BottomFilterSheetState();
}

class _BottomFilterSheetState extends State<BottomFilterSheet> {
  // filter provider
  late Filter filters = Provider.of<Filter>(context, listen: false);
  late Auth authData = Provider.of<Auth>(context, listen: false);

  // price slider
  late RangeValues _priceRange;

  // sort
  late List<String?> _sortList;

  @override
  void initState() {
    _priceRange = filters.priceRange;
    if (authData.isAuth) {
      _sortList = filters.sortListAuth.keys.toList();
    } else {
      _sortList = filters.sortList.keys.toList();
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        // Open filters
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
      icon: const Icon(Icons.filter_list),
      label: const Text('Filter'),
    );
  }

  Widget _showPopup() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child:
          StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Butikk',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Semantics(
                        label: 'Reset alle filter',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            filters.resetFilters();
                            _priceRange = filters.priceRange;
                            Navigator.pop(context);
                          },
                          child: const Text('Reset Alle',
                              style: TextStyle(color: Colors.pink)),
                        ),
                      )
                    ],
                  ),
                  Consumer<Filter>(
                    builder: (context, flt, _) {
                      if (!flt.storesLoading && flt.storeList.isEmpty) {
                        flt.getStores();
                      }
                      return flt.storeList.isNotEmpty
                          ? DropDownMultiSelect(
                              onChanged: (List<String> x) {
                                mystate(() {
                                  filters.selectedStores = x;
                                  filters.setStore();
                                });
                              },
                              options:
                                  filters.storeList.map((e) => e.name).toList(),
                              stores: filters.storeList,
                              selectedValues: filters.selectedStores,
                              whenEmpty: 'Velg butikker',
                            )
                          : Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Pris',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 500,
                    divisions: 20,
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end == 500
                          ? _priceRange.end.round().toString() + ' +'
                          : _priceRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      mystate(() {
                        _priceRange = values;
                        filters.setPriceRange(_priceRange);
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Sortering',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      hint: Text("Select Year"),
                      value: filters.sortIndex,
                      items: _sortList.map((value) {
                        return DropdownMenuItem<String>(
                          child: Center(child: Text(value!)),
                          value: value,
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        mystate(() {
                          filters.sortIndex = value!;
                          filters.setSortBy(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stil',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Semantics(
                        label: 'Velg alle stiler',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            mystate(() {
                              if (!filters.styleSelectedList.contains(true)) {
                                filters.styleSelectedList = List<bool>.filled(
                                  filters.styleList.length,
                                  true,
                                );
                              } else {
                                filters.styleSelectedList = List<bool>.filled(
                                  filters.styleList.length,
                                  false,
                                );
                              }
                            });
                          },
                          child: const Text('Velg alle',
                              style: TextStyle(color: Colors.pink)),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      filters.styleList.length,
                      (index) {
                        return _filter(
                          filters.styleSelectedList,
                          filters.styleList[index].keys.first,
                          index,
                          filters.setStyle,
                          mystate,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Produktutvalg',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Semantics(
                        label: 'Velg alle produktutvalg',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            mystate(() {
                              if (!filters.productSelectionSelectedList
                                  .contains(true)) {
                                filters.productSelectionSelectedList =
                                    List<bool>.filled(
                                  filters.productSelectionList.length,
                                  true,
                                );
                              } else {
                                filters.productSelectionSelectedList =
                                    List<bool>.filled(
                                  filters.productSelectionList.length,
                                  false,
                                );
                              }
                            });
                          },
                          child: const Text('Velg alle',
                              style: TextStyle(color: Colors.pink)),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      filters.productSelectionList.length,
                      (index) {
                        return _filter(
                          filters.productSelectionSelectedList,
                          filters.productSelectionList[index].keys.first,
                          index,
                          filters.setProductSelection,
                          mystate,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Ølslipp',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Consumer<Filter>(
                    builder: (context, flt, _) {
                      return flt.releaseList.isNotEmpty
                          ? Wrap(
                              spacing: 8,
                              children: List.generate(
                                filters.releaseList.length,
                                (index) {
                                  return _filter(
                                    filters.releaseSelectedList,
                                    filters.releaseList[index],
                                    index,
                                    filters.setRelease,
                                    mystate,
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Ingen aktive ølslipp.'),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                      authData.isAuth
                          ? 'Untappd Innsjekket'
                          : 'Untappd Innsjekket - Innlogging kreves',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children:
                        List.generate(filters.checkinList.length, (index) {
                      return _radio(
                        filters.checkinList[index],
                        index,
                        filters.checkIn,
                        filters.setCheckin,
                        mystate,
                      );
                    }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                      authData.isAuth
                          ? 'Untappd Ønskeliste'
                          : 'Untappd Ønskeliste - Innlogging kreves',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children:
                        List.generate(filters.wishlistList.length, (index) {
                      return _radio(
                        filters.wishlistList[index],
                        index,
                        filters.wishlisted,
                        filters.setWishlisted,
                        mystate,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _radio(
      String value, int index, int selected, Function setSelected, mystate) {
    return ChoiceChip(
      label: Text(value,
          style: TextStyle(color: selected == index ? Colors.white : null)),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1,
              color: selected == index
                  ? Colors.pink
                  : Theme.of(context).focusColor),
          borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      pressElevation: 0,
      selectedColor: Colors.pink,
      backgroundColor: Theme.of(context).backgroundColor,
      selected:
          (selected == 0) ? (index == 0 ? true : false) : selected == index,
      onSelected: (bool selected) {
        authData.isAuth
            ? mystate(() {
                setSelected(index);
              })
            : null;
      },
    );
  }

  Widget _filter(
      var selectedData, String value, int index, Function setFilter, mystate) {
    return FilterChip(
      label: Text(value),
      labelStyle:
          TextStyle(color: selectedData[index] == true ? Colors.white : null),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1,
              color: selectedData[index] == true
                  ? Colors.pink
                  : Theme.of(context).focusColor),
          borderRadius: BorderRadius.circular(10)),
      selected: selectedData[index],
      onSelected: (bool selected) {
        mystate(() {
          setFilter(index, selected);
        });
      },
      elevation: 0,
      pressElevation: 0,
      backgroundColor: Theme.of(context).backgroundColor,
      selectedColor: Colors.pink,
      checkmarkColor: Colors.white,
    );
  }
}
