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
    final cart = Provider.of<Cart>(context, listen: false);
    final initialSize = cart.useOverviewStoreSelection ? 0.65 : 0.8;

    return IconButton(
      onPressed: () {
        final sheetController = DraggableScrollableController();

        showModalBottomSheet<void>(
          isScrollControlled: true,
          useSafeArea: true,
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              controller: sheetController,
              initialChildSize: initialSize,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return _showPopup(scrollController, sheetController);
              },
            );
          },
        );
      },
      icon: const Icon(
        Icons.settings,
        semanticLabel: "Instillinger",
      ),
    );
  }

  Widget _showPopup(
    ScrollController scrollController,
    DraggableScrollableController sheetController,
  ) {
    final cart = Provider.of<Cart>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter mystate) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: colors.onSurfaceVariant,
                    size: 22.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Innstillinger',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              indent: 20.w,
              endIndent: 20.w,
              color: colors.outlineVariant,
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.all(20.r),
                children: [
                  // Sorting section
                  _buildSectionHeader(
                    context,
                    icon: Icons.sort,
                    title: 'Sortering',
                  ),
                  SizedBox(height: 12.h),
                  SingleSelectDropdown<String>(
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

                  SizedBox(height: 24.h),

                  // Store settings section
                  _buildSectionHeader(
                    context,
                    icon: Icons.store_outlined,
                    title: 'Butikkvalg',
                  ),
                  SizedBox(height: 8.h),

                  _buildSwitchTile(
                    context,
                    title: 'Grå ut varer uten lager',
                    subtitle: 'Marker varer som ikke er på lager',
                    value: cart.greyNoStock,
                    onChanged: (value) {
                      mystate(() {
                        cart.greyNoStock = value;
                        cart.saveCartSettings();
                        initCartSettings();
                      });
                    },
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Skjul varer uten lager',
                    subtitle: 'Vis kun varer som er på lager',
                    value: cart.hideNoStock,
                    onChanged: (value) {
                      mystate(() {
                        cart.hideNoStock = value;
                        cart.saveCartSettings();
                        initCartSettings();
                      });
                    },
                  ),

                  _buildSwitchTile(
                    context,
                    title: 'Synkroniser med oversikt',
                    subtitle: 'Bruk samme butikkvalg som hovedoversikten',
                    value: cart.useOverviewStoreSelection,
                    onChanged: (value) {
                      mystate(() {
                        cart.useOverviewStoreSelection = value;
                        cart.saveCartSettings();
                        initCartSettings();
                      });
                      // Animate sheet size
                      final targetSize = value ? 0.65 : 0.8;
                      sheetController.animateTo(
                        targetSize,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),

                  if (!cart.useOverviewStoreSelection)
                    FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          _buildSectionHeader(
                            context,
                            icon: Icons.location_on_outlined,
                            title: 'Velg butikker',
                          ),
                          SizedBox(height: 12.h),
                          Consumer<Filter>(
                            builder: (context, filters, _) {
                              return MultiSelectDropdown<String>(
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
                                selectedLabel: (selected) => selected.isEmpty
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 18.r,
          color: colors.primary,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Switch(
                  value: value,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
