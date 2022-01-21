import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import '../../providers/auth.dart';
import '../../models/store.dart';

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
    if (filters.storeList.isEmpty) {
      filters.getStores();
    }
    _priceRange = filters.priceRange;
    _sortList = filters.sortList.keys.toList();
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
      height: MediaQuery.of(context).size.height * 0.6,
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
                      GestureDetector(
                        onTap: () {
                          filters.resetFilters();
                          _priceRange = filters.priceRange;
                          Navigator.pop(context);
                        },
                        child: const Text('Reset Alle',
                            style: TextStyle(color: Colors.pink)),
                      )
                    ],
                  ),
                  FutureBuilder<List<Store>>(
                    future: filters.getStores(),
                    builder: (context, snapshot) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Card(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text("Velg Butikk"),
                                value: filters.storeId,
                                items: filters.storeList.map((value) {
                                  return DropdownMenuItem<String>(
                                    child: Row(
                                      mainAxisAlignment: value.distance != null
                                          ? MainAxisAlignment.spaceBetween
                                          : MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(value.name),
                                          flex: 1,
                                        ),
                                        Flexible(
                                          child: Text(
                                            value.distance != null
                                                ? (value.distance! / 1000)
                                                        .toStringAsFixed(1) +
                                                    'Km'
                                                : '',
                                          ),
                                          flex: 1,
                                        ),
                                      ],
                                    ),
                                    value: value.id,
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  mystate(() {
                                    filters.storeId = value!;
                                    filters.setStore(value);
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      );
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
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Velg Sortering"),
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
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Type',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: List.generate(filters.styleList.length, (index) {
                      return _filter(
                          filters.styleSelectedList,
                          filters.styleList[index].keys.first,
                          index,
                          filters.setStyle,
                          mystate);
                    }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                      authData.isAuth
                          ? 'Innsjekket'
                          : 'Innsjekket - Innlogging kreves',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children:
                        List.generate(filters.checkinList.length, (index) {
                      return _radioCheckin(
                          filters.checkinList[index], index, mystate);
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

  Widget _radioCheckin(String value, int index, mystate) {
    return ChoiceChip(
        label: Text(value,
            style: TextStyle(
                color: filters.checkIn == index
                    ? Colors.white
                    : const Color(0xFF515151))),
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1,
                color:
                    filters.checkIn == index ? Colors.pink : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        pressElevation: 0,
        selectedColor: Colors.pink,
        backgroundColor: Colors.white,
        selected: (filters.checkIn == 0)
            ? (index == 0 ? true : false)
            : filters.checkIn == index,
        onSelected: (bool selected) {
          authData.isAuth
              ? mystate(() {
                  filters.setCheckin(index);
                })
              : null;
        });
  }

  Widget _filter(
      var selectedData, String value, int index, Function setFilter, mystate) {
    return FilterChip(
      label: Text(value),
      labelStyle: TextStyle(
          color: selectedData[index] == true
              ? Colors.white
              : const Color(0xFF515151)),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              width: 1,
              color: selectedData[index] == true
                  ? Colors.pink
                  : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10)),
      selected: selectedData[index],
      onSelected: (bool selected) {
        mystate(() {
          setFilter(index, selected);
        });
      },
      elevation: 0,
      pressElevation: 0,
      backgroundColor: Colors.white,
      selectedColor: Colors.pink,
      checkmarkColor: Colors.white,
    );
  }
}
