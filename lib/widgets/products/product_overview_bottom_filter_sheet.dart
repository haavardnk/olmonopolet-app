import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flag/flag.dart';

import '../../models/country.dart';
import '../../providers/filter.dart';
import '../../assets/constants.dart';

class ProductOverviewBottomFilterSheet extends StatefulWidget {
  const ProductOverviewBottomFilterSheet({super.key});

  @override
  ProductOverviewBottomFilterSheetState createState() =>
      ProductOverviewBottomFilterSheetState();
}

class ProductOverviewBottomFilterSheetState
    extends State<ProductOverviewBottomFilterSheet> {
  // filter provider
  late Filter filters = Provider.of<Filter>(context, listen: false);

  // price slider
  late RangeValues _priceRange;
  late RangeValues _pricePerVolumeRange;
  late RangeValues _alcoholRange;

  // sort
  late List<String?> _sortList;

  // style
  final _multiKey = GlobalKey<DropdownSearchState<String>>();

  @override
  void initState() {
    _priceRange = filters.priceRange;
    _pricePerVolumeRange = filters.pricePerVolumeRange;
    _alcoholRange = filters.alcoholRange;
    _sortList = sortList.keys.toList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
        ).whenComplete(() => filters.setFilters());
      },
      icon: const Icon(
        Icons.filter_list,
        semanticLabel: "Filter",
      ),
    );
  }

  Widget _showPopup() {
    final mediaQueryData = MediaQuery.of(context);
    return SizedBox(
      height: mediaQueryData.size.height * 0.60,
      child:
          StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Stack(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            showSettingsPopup(
                              context,
                              mystate,
                            );
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Instillinger')),
                      TextButton(
                          onPressed: () {
                            filters.resetFilters();
                            _priceRange = filters.priceRange;
                            _pricePerVolumeRange = filters.pricePerVolumeRange;
                            _alcoholRange = filters.alcoholRange;
                            Navigator.pop(context);
                          },
                          child: const Text('Reset Alle')),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
            ),
            Flexible(
              child: ListView(
                padding: mediaQueryData.size.width > 600 &&
                        mediaQueryData.orientation == Orientation.landscape
                    ? EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: mediaQueryData.size.width * 0.15,
                      )
                    : const EdgeInsets.fromLTRB(16, 5, 16, 16),
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Butikklager',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Semantics(
                        label: 'Reset valgte butikker',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            mystate(() {
                              filters.selectedStores = [];
                              filters.setStore();
                            });
                          },
                          child: Text(
                            'Velg alle',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
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
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              child: DropdownSearch<String>.multiSelection(
                                popupProps: PopupPropsMultiSelection.dialog(
                                  showSelectedItems: true,
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      labelText: 'Søk',
                                      prefixIcon: const Icon(
                                        Icons.search,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                  ),
                                  itemBuilder:
                                      (context, item, isDisabled, isSelected) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: ListTile(
                                        title: Text(item),
                                        subtitle: Text(filters
                                                    .storeList.isNotEmpty &&
                                                filters.storeList
                                                        .firstWhere((element) =>
                                                            element.name ==
                                                            item)
                                                        .distance !=
                                                    null
                                            ? '${filters.storeList.firstWhere((element) => element.name == item).distance!.toStringAsFixed(0)}km'
                                            : ''),
                                      ),
                                    );
                                  },
                                ),
                                dropdownBuilder: (context, selectedItems) {
                                  return Text(
                                    filters.selectedStores.isNotEmpty
                                        ? filters.selectedStores
                                            .reduce((a, b) => '$a, $b')
                                        : 'Alle butikker',
                                    style: const TextStyle(fontSize: 16),
                                  );
                                },
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 23,
                                      horizontal: 10,
                                    ),
                                  ),
                                ),
                                items: (filter, loadProps) => filters.storeList
                                    .map((e) => e.name)
                                    .toList(),
                                onChanged: (List<String> x) {
                                  mystate(() {
                                    filters.selectedStores = x;
                                    filters.setStore();
                                  });
                                },
                                selectedItems: filters.selectedStores,
                              ),
                            )
                          : const Center(child: CircularProgressIndicator());
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pris',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Pris per liter',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 500,
                          divisions: 20,
                          labels: RangeLabels(
                            _priceRange.start.round().toString(),
                            _priceRange.end == 500
                                ? '${_priceRange.end.round()} +'
                                : _priceRange.end.round().toString(),
                          ),
                          onChanged: (RangeValues values) {
                            mystate(() {
                              _priceRange = values;
                              filters.setPriceRange(_priceRange);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RangeSlider(
                          values: _pricePerVolumeRange,
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          labels: RangeLabels(
                            _pricePerVolumeRange.start.round().toString(),
                            _pricePerVolumeRange.end == 1000
                                ? '${_pricePerVolumeRange.end.round()} +'
                                : _pricePerVolumeRange.end.round().toString(),
                          ),
                          onChanged: (RangeValues values) {
                            mystate(() {
                              _pricePerVolumeRange = values;
                              filters
                                  .setPricePerVolumeRange(_pricePerVolumeRange);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Sortering',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: DropdownSearch<String>(
                      popupProps: const PopupProps.dialog(),
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 23,
                            horizontal: 10,
                          ),
                        ),
                      ),
                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem!,
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                      items: (filter, loadProps) =>
                          _sortList.map((value) => value!).toList(),
                      selectedItem: filters.sortIndex,
                      onChanged: (String? x) {
                        mystate(() {
                          filters.sortIndex = x!;
                          filters.setSortBy(x);
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
                      Row(
                        children: [
                          Semantics(
                            label: filters.styleChoice == 0
                                ? 'Bytt til avansert stilvalg'
                                : 'Bytt til standard stilvalg',
                            button: true,
                            child: InkWell(
                              onTap: () {
                                mystate(() {
                                  filters.setStyleChoice(
                                      filters.styleChoice == 0 ? 1 : 0);
                                });
                              },
                              child: Text(
                                filters.styleChoice == 0
                                    ? 'Bytt til Untappd stiler'
                                    : 'Bytt til standard stiler',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Semantics(
                            label: 'Velg alle stiler',
                            button: true,
                            child: InkWell(
                              onTap: () {
                                mystate(() {
                                  if (filters.styleChoice == 0) {
                                    filters.selectedStyles.isNotEmpty
                                        ? filters.selectedStyles = []
                                        : filters.selectedStyles =
                                            beermonopolyStyleList.keys.toList();
                                  } else {
                                    filters.selectedStyles = [];
                                  }

                                  filters.setStyle();
                                });
                              },
                              child: Text(
                                'Velg alle',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Consumer<Filter>(
                    builder: (context, _, __) {
                      List<String> styleList = (filters.styleChoice == 0)
                          ? beermonopolyStyleList.keys.toList()
                          : untappdStyleList;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: filters.styleChoice == 0
                            ? Wrap(
                                key: ValueKey(filters.styleChoice),
                                spacing: 8,
                                children: List.generate(
                                  (filters.styleChoice == 0)
                                      ? beermonopolyStyleList.keys
                                          .toList()
                                          .length
                                      : untappdStyleList.length,
                                  (index) {
                                    return FilterChip(
                                      label: Text(styleList[index]),
                                      shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(24)),
                                      selected: filters.selectedStyles
                                          .contains(styleList[index]),
                                      onSelected: (bool selected) {
                                        mystate(() {
                                          filters.selectedStyles
                                                  .contains(styleList[index])
                                              ? filters.selectedStyles
                                                  .remove(styleList[index])
                                              : filters.selectedStyles
                                                  .add(styleList[index]);
                                          filters.setStyle();
                                        });
                                      },
                                      elevation: 0,
                                      pressElevation: 0,
                                    );
                                  },
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: DropdownSearch<String>.multiSelection(
                                  key: _multiKey,
                                  popupProps: PopupPropsMultiSelection.dialog(
                                    showSearchBox: true,
                                    showSelectedItems: true,
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        labelText: 'Søk',
                                        prefixIcon: const Icon(
                                          Icons.search,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                    ),
                                    itemBuilder: (context, item, isDisabled,
                                        isSelected) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: ListTile(
                                          title: Text(item),
                                        ),
                                      );
                                    },
                                    containerBuilder: (context, popupWidget) {
                                      return Column(
                                        children: [
                                          Wrap(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _multiKey.currentState!
                                                            .popupIsAllItemSelected
                                                        ? _multiKey.currentState
                                                            ?.popupDeselectAllItems()
                                                        : _multiKey.currentState
                                                            ?.popupSelectAllItems();
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize:
                                                        const Size(50, 30),
                                                    textStyle: const TextStyle(
                                                        fontSize: 13),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                  ),
                                                  child: const Text('Alle'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(child: popupWidget),
                                        ],
                                      );
                                    },
                                  ),
                                  dropdownBuilder: (context, selectedItems) {
                                    return Text(
                                      filters.style.isNotEmpty
                                          ? filters.selectedStyles.join(', ')
                                          : 'Alle stiler',
                                      style: const TextStyle(fontSize: 16),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 23,
                                        horizontal: 10,
                                      ),
                                    ),
                                  ),
                                  items: (filter, loadProps) => styleList,
                                  onChanged: (List<String> x) {
                                    mystate(() {
                                      filters.selectedStyles = x;
                                      filters.setStyle();
                                    });
                                  },
                                  selectedItems: filters.selectedStyles,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Land',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Semantics(
                        label: 'Reset valgte land',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            mystate(() {
                              filters.selectedCountries = [];
                              filters.setCountry();
                            });
                          },
                          child: Text(
                            'Velg alle',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: DropdownSearch<Country>.multiSelection(
                      popupProps: PopupPropsMultiSelection.dialog(
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Søk',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isDisabled, isSelected) {
                          return ListTile(
                            leading:
                                item.isoCode != null && item.isoCode!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: Flag.fromString(
                                          item.isoCode!,
                                          height: 20,
                                          width: 20 * 4 / 3,
                                        ),
                                      )
                                    : const SizedBox(width: 20 * 4 / 3),
                            title: Text(item.name),
                          );
                        },
                      ),
                      dropdownBuilder: (context, selectedItems) {
                        return Text(
                          selectedItems.isNotEmpty
                              ? selectedItems.map((c) => c.name).join(', ')
                              : 'Alle land',
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                      decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 23,
                            horizontal: 10,
                          ),
                        ),
                      ),
                      compareFn: (item1, item2) => item1.name == item2.name,
                      items: (filter, loadProps) async {
                        return await filters.getCountries();
                      },
                      onChanged: (List<Country> x) {
                        mystate(() {
                          filters.selectedCountries =
                              x.map((c) => c.name).toList();
                          filters.setCountry();
                        });
                      },
                      selectedItems: filters.selectedCountries
                          .map((name) => Country(name: name))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Alkohol %',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: _alcoholRange,
                    min: 0,
                    max: 15,
                    divisions: 15,
                    labels: RangeLabels(
                      _alcoholRange.start.round().toString(),
                      _alcoholRange.end == 15
                          ? '${_alcoholRange.end.round()} +'
                          : _alcoholRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      mystate(() {
                        _alcoholRange = values;
                        filters.setAlcoholRange(_alcoholRange);
                      });
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.ideographic,
                        children: [
                          Text(
                            'Allergener',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '(NB: Ekskluderer valgte)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      Semantics(
                        label: 'Velg alle allergener',
                        button: true,
                        child: InkWell(
                          onTap: () {
                            mystate(() {
                              if (!filters.excludeAllergensSelectedList
                                  .contains(true)) {
                                filters.excludeAllergensSelectedList =
                                    List<bool>.filled(
                                  excludeAllergensList.length,
                                  true,
                                );
                              } else {
                                filters.excludeAllergensSelectedList =
                                    List<bool>.filled(
                                  excludeAllergensList.length,
                                  false,
                                );
                              }
                              filters.setFilters();
                            });
                          },
                          child: Text(
                            'Velg alle',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      excludeAllergensList.length,
                      (index) {
                        return _filter(
                          filters.excludeAllergensSelectedList,
                          excludeAllergensList[index].keys.first,
                          index,
                          filters.setExcludeAllergensSelection,
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
                                  productSelectionList.length,
                                  true,
                                );
                              } else {
                                filters.productSelectionSelectedList =
                                    List<bool>.filled(
                                  productSelectionList.length,
                                  false,
                                );
                              }
                              filters.setFilters();
                            });
                          },
                          child: Text(
                            'Velg alle',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      productSelectionList.length,
                      (index) {
                        return _filter(
                          filters.productSelectionSelectedList,
                          productSelectionList[index].keys.first,
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
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      Text(
                        'Bestilling',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '(NB: Ikke filtrer på butikklager)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      deliveryList.length,
                      (index) {
                        return _filter(
                          filters.deliverySelectedList,
                          deliveryList[index],
                          index,
                          filters.setDeliverySelection,
                          mystate,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Nyhetslansering',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Consumer<Filter>(
                    builder: (context, flt, _) {
                      return flt.releaseList.isNotEmpty
                          ? Wrap(
                              spacing: 8,
                              children: List.generate(
                                3,
                                (index) {
                                  return _filter(
                                    filters.releaseSelectedList,
                                    filters.releaseList[index].name,
                                    index,
                                    filters.setRelease,
                                    mystate,
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Ingen aktive ølslipp.'),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _filter(
      var selectedData, String value, int index, Function setFilter, mystate) {
    return FilterChip(
      label: Text(value),
      shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1),
          borderRadius: BorderRadius.circular(24)),
      selected: selectedData[index],
      onSelected: (bool selected) {
        mystate(() {
          setFilter(index, selected);
        });
      },
      elevation: 0,
      pressElevation: 0,
    );
  }

  Future<void> showSettingsPopup(
      BuildContext context, StateSetter mystate) async {
    Widget continueButton = ElevatedButton(
      onPressed: () {
        filters.saveFilters();
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
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Stil utvalg',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Consumer<Filter>(
            builder: (context, _, __) => SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: <ButtonSegment<int>>[
                  ...styleChoiceList.asMap().entries.map(
                    (style) {
                      return ButtonSegment<int>(
                        value: style.key,
                        label: Text(style.value),
                      );
                    },
                  )
                ],
                showSelectedIcon: false,
                selected: <int>{filters.styleChoice},
                onSelectionChanged: (Set<int> newSelection) {
                  filters.setStyleChoice(newSelection.first);
                },
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Husk filter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Semantics(
                label: 'Velg alle',
                button: true,
                child: InkWell(
                  onTap: () {
                    mystate(() {
                      if (filters.filterSaveSettings[0]['save'] == true) {
                        for (var element in filters.filterSaveSettings) {
                          element['save'] = false;
                        }
                      } else {
                        for (var element in filters.filterSaveSettings) {
                          element['save'] = true;
                        }
                      }
                      filters.saveFilterSettings();
                    });
                  },
                  child: Text(
                    'Velg alle',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 400,
            width: 300,
            child: ListView.builder(
              itemCount: filters.filterSaveSettings.length,
              itemBuilder: (context, index) {
                return Consumer<Filter>(
                  builder: (context, _, __) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: filters.filterSaveSettings[index]['save'],
                    title: Text(filters.filterSaveSettings[index]['text']),
                    onChanged: (bool? newValue) {
                      mystate(() {
                        filters.filterSaveSettings[index]['save'] = newValue!;
                        filters.saveFilterSettings();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
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
