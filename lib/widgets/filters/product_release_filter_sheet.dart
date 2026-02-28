import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flag/flag.dart';

import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../../models/release.dart';
import '../../models/country.dart';
import '../../assets/constants.dart';
import '../../services/api.dart';
import '../../utils/date_utils.dart';
import 'filter_section.dart';
import 'multi_select_dropdown.dart';
import 'range_filters.dart';

class ProductReleaseFilterSheet extends StatelessWidget {
  final Release release;

  const ProductReleaseFilterSheet({super.key, required this.release});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showFilterSheet(context),
      icon: const Icon(Icons.tune, semanticLabel: "Filter"),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;

    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: _ReleaseFilterSheetContent(
                scrollController: scrollController,
                release: release,
                client: client,
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(() => filters.setFilters());
  }
}

class _ReleaseFilterSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final Release release;
  final http.Client client;

  const _ReleaseFilterSheetContent({
    required this.scrollController,
    required this.release,
    required this.client,
  });

  @override
  State<_ReleaseFilterSheetContent> createState() =>
      _ReleaseFilterSheetContentState();
}

class _ReleaseFilterSheetContentState
    extends State<_ReleaseFilterSheetContent> {
  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final isWide = 1.sw > 600 && orientation == Orientation.landscape;

    return Column(
      children: [
        _buildHandle(colors),
        _buildHeader(context, filters, colors),
        Divider(height: 1, color: colors.outlineVariant),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: isWide
                ? EdgeInsets.symmetric(vertical: 8.h, horizontal: 0.15.sw)
                : EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            children: [
              _ReleaseSortFilter(parentSetState: setState),
              if (widget.release.productSelections.length > 1)
                _ReleaseProductSelectionFilter(
                  parentSetState: setState,
                  release: widget.release,
                ),
              _ReleaseChristmasBeerFilter(parentSetState: setState),
              const Divider(height: 16),
              _ReleasePriceRangeFilter(parentSetState: setState),
              _ReleaseAlcoholRangeFilter(parentSetState: setState),
              const Divider(height: 16),
              _ReleaseMainCategoryFilter(parentSetState: setState),
              _ReleaseStyleFilter(
                parentSetState: setState,
                release: widget.release,
                client: widget.client,
              ),
              _ReleaseCountryFilter(
                parentSetState: setState,
                release: widget.release,
                client: widget.client,
              ),
              const Divider(height: 16),
              _ReleaseAllergensFilter(parentSetState: setState),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHandle(ColorScheme colors) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: colors.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, Filter filters, ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => _showSortSettingsInfo(context),
            icon: const Icon(Icons.info_outline, size: 20),
            label: const Text('Lanseringsfiltre'),
            style:
                TextButton.styleFrom(foregroundColor: colors.onSurfaceVariant),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  filters.resetReleaseFilters();
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Nullstill alle'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundColor: colors.onSurface,
                ),
                child: const Text('Bruk'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSortSettingsInfo(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lanseringsfiltre'),
        content: Text(
          'Filtrene på denne siden gjelder kun for denne lanseringen og blir nullstilt når du forlater siden.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ReleaseSortFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const _ReleaseSortFilter({required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Sortering',
        icon: Icons.sort,
        child: SingleSelectDropdown<String>(
          items: sortList.keys.toList(),
          selectedItem: flt.releaseSortIndex,
          itemLabel: (item) => item,
          hintText: 'Velg sortering',
          onChanged: (x) {
            if (x != null) {
              parentSetState(() {
                filters.releaseSortIndex = x;
                filters.setSortBy(x, true);
              });
            }
          },
        ),
      ),
    );
  }
}

class _ReleaseProductSelectionFilter extends StatelessWidget {
  final StateSetter parentSetState;
  final Release release;

  const _ReleaseProductSelectionFilter({
    required this.parentSetState,
    required this.release,
  });

  String _getDisplayName(String selection) {
    if (selection.isEmpty) return 'Alle produktutvalg';
    return productSelectionDisplayNameList[selection] ?? selection;
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final selections = ['', ...release.productSelections];

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Produktutvalg',
        icon: Icons.category_outlined,
        child: SingleSelectDropdown<String>(
          items: selections,
          selectedItem: flt.releaseProductSelectionChoice,
          itemLabel: _getDisplayName,
          hintText: 'Alle produktutvalg',
          onChanged: (x) {
            if (x != null) {
              parentSetState(() {
                filters.setReleaseProductSelectionChoice(x);
              });
            }
          },
        ),
      ),
    );
  }
}

class _ReleaseChristmasBeerFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const _ReleaseChristmasBeerFilter({required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    if (!isHolidaySeason()) {
      return const SizedBox.shrink();
    }

    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Text(
              '🎄',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'Kun juleøl',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: flt.releaseChristmasBeerOnly,
                onChanged: (value) {
                  filters.setReleaseChristmasBeerOnly(value);
                  parentSetState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleasePriceRangeFilter extends StatefulWidget {
  final StateSetter parentSetState;

  const _ReleasePriceRangeFilter({required this.parentSetState});

  @override
  State<_ReleasePriceRangeFilter> createState() =>
      _ReleasePriceRangeFilterState();
}

class _ReleasePriceRangeFilterState extends State<_ReleasePriceRangeFilter> {
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    final filters = Provider.of<Filter>(context, listen: false);
    _priceRange = filters.releasePriceRange;
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return RangeFilter(
      title: 'Pris',
      icon: Icons.payments_outlined,
      unit: 'kr',
      values: _priceRange,
      min: 0,
      max: 500,
      divisions: 20,
      onChanged: (v) {
        setState(() => _priceRange = v);
        widget.parentSetState(() {});
        filters.setReleasePriceRange(_priceRange);
      },
    );
  }
}

class _ReleaseAlcoholRangeFilter extends StatefulWidget {
  final StateSetter parentSetState;

  const _ReleaseAlcoholRangeFilter({required this.parentSetState});

  @override
  State<_ReleaseAlcoholRangeFilter> createState() =>
      _ReleaseAlcoholRangeFilterState();
}

class _ReleaseAlcoholRangeFilterState
    extends State<_ReleaseAlcoholRangeFilter> {
  late RangeValues _alcoholRange;

  @override
  void initState() {
    super.initState();
    _alcoholRange =
        Provider.of<Filter>(context, listen: false).releaseAlcoholRange;
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);

    return RangeFilter(
      title: 'Alkohol',
      icon: Icons.percent,
      unit: '%',
      values: _alcoholRange,
      min: 0,
      max: 15,
      divisions: 15,
      onChanged: (v) {
        setState(() => _alcoholRange = v);
        widget.parentSetState(() {});
        filters.setReleaseAlcoholRange(_alcoholRange);
      },
    );
  }
}

class _ReleaseStyleFilter extends StatelessWidget {
  final StateSetter parentSetState;
  final Release release;
  final http.Client client;

  const _ReleaseStyleFilter({
    required this.parentSetState,
    required this.release,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Stil',
        icon: Icons.local_bar_outlined,
        resetLabel:
            filters.releaseSelectedStyles.isNotEmpty ? 'Nullstill' : null,
        onReset: filters.releaseSelectedStyles.isNotEmpty
            ? () => parentSetState(() {
                  filters.releaseSelectedStyles = [];
                  filters.setReleaseStyle();
                })
            : null,
        child: InkWell(
          onTap: () => _showStyleDialog(context, filters),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    filters.releaseSelectedStyles.isEmpty
                        ? 'Alle stiler'
                        : filters.releaseSelectedStyles.length == 1
                            ? filters.releaseSelectedStyles.first
                            : '${filters.releaseSelectedStyles.length} stiler valgt',
                    style: TextStyle(
                      fontSize: 13,
                      color: filters.releaseSelectedStyles.isNotEmpty
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(Icons.expand_more,
                    size: 20, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showStyleDialog(BuildContext context, Filter filters) async {
    await showDialog(
      context: context,
      builder: (_) => _ReleaseStyleDialogContent(
        filters: filters,
        parentSetState: parentSetState,
        release: release,
        client: client,
      ),
    );
  }
}

class _ReleaseStyleDialogContent extends StatefulWidget {
  final Filter filters;
  final StateSetter parentSetState;
  final Release release;
  final http.Client client;

  const _ReleaseStyleDialogContent({
    required this.filters,
    required this.parentSetState,
    required this.release,
    required this.client,
  });

  @override
  State<_ReleaseStyleDialogContent> createState() =>
      _ReleaseStyleDialogContentState();
}

class _ReleaseStyleDialogContentState
    extends State<_ReleaseStyleDialogContent> {
  final _searchController = TextEditingController();
  var _searchQuery = '';
  List<String> _styles = [];
  bool _isLoading = true;

  Filter get _filters => widget.filters;

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStyles() async {
    try {
      final styles =
          await ApiHelper.getReleaseStyles(widget.client, widget.release.name);
      if (mounted) {
        setState(() {
          _styles = styles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> get _filteredStyles => _searchQuery.isEmpty
      ? _styles
      : _styles.where((s) => s.toLowerCase().contains(_searchQuery)).toList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filteredStyles;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12).copyWith(left: 16, right: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Søk etter stil...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Flexible(child: _buildList(filtered, colors)),
            Divider(height: 1, color: colors.outlineVariant),
            _buildFooter(filtered),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<String> styles, ColorScheme colors) {
    if (_isLoading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (styles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Ingen stiler funnet',
              style: TextStyle(color: colors.onSurfaceVariant)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: styles.length,
      itemBuilder: (context, i) {
        final style = styles[i];
        final isSelected = _filters.releaseSelectedStyles.contains(style);
        return ListTile(
          dense: true,
          title: Text(style),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: colors.primary)
              : null,
          onTap: () {
            setState(() {
              isSelected
                  ? _filters.releaseSelectedStyles.remove(style)
                  : _filters.releaseSelectedStyles.add(style);
              _filters.setReleaseStyle(_styles);
            });
            widget.parentSetState(() {});
          },
        );
      },
    );
  }

  Widget _buildFooter(List<String> filtered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var style in filtered) {
                    if (!_filters.releaseSelectedStyles.contains(style)) {
                      _filters.releaseSelectedStyles.add(style);
                    }
                  }
                  _filters.setReleaseStyle(_styles);
                });
                widget.parentSetState(() {});
              },
              child: const Text('Velg alle'),
            )
          else if (_filters.releaseSelectedStyles.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _filters.releaseSelectedStyles = [];
                  _filters.setReleaseStyle(_styles);
                });
                widget.parentSetState(() {});
              },
              child: const Text('Nullstill'),
            ),
          const Spacer(),
          FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ferdig')),
        ],
      ),
    );
  }
}

class _ReleaseCountryFilter extends StatelessWidget {
  final StateSetter parentSetState;
  final Release release;
  final http.Client client;

  const _ReleaseCountryFilter({
    required this.parentSetState,
    required this.release,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Land',
        icon: Icons.public,
        resetLabel:
            filters.releaseSelectedCountries.isNotEmpty ? 'Nullstill' : null,
        onReset: filters.releaseSelectedCountries.isNotEmpty
            ? () => parentSetState(() {
                  filters.releaseSelectedCountries = [];
                  filters.setReleaseCountry();
                })
            : null,
        child: MultiSelectDropdown<Country>(
          items: const [],
          selectedItems: filters.releaseSelectedCountries
              .map((name) => Country(name: name))
              .toList(),
          itemLabel: (c) => c.name,
          itemLeading: (c) => c.isoCode?.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Flag.fromString(c.isoCode!, height: 18, width: 24),
                )
              : const SizedBox(width: 24),
          hintText: 'Alle land',
          searchHint: 'Søk etter land...',
          selectedLabel: (sel) => sel.isEmpty
              ? 'Alle land'
              : sel.length == 1
                  ? sel.first.name
                  : '${sel.length} land valgt',
          selectedDisplayBuilder: (context, sel) {
            if (sel.isEmpty || sel.length > 1) return null;
            final item = sel.first;
            return Row(
              children: [
                if (item.isoCode?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child:
                          Flag.fromString(item.isoCode!, height: 14, width: 20),
                    ),
                  ),
                Flexible(
                  child: Text(
                    item.name,
                    style: TextStyle(fontSize: 13, color: colors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
          asyncItems: () async {
            return await ApiHelper.getReleaseCountries(
                this.client, release.name);
          },
          onChanged: (sel) => parentSetState(() {
            filters.releaseSelectedCountries = sel.map((c) => c.name).toList();
            filters.setReleaseCountry();
          }),
        ),
      ),
    );
  }
}

class _ReleaseMainCategoryFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const _ReleaseMainCategoryFilter({required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Kategori',
        icon: Icons.local_drink_outlined,
        resetLabel: filters.releaseMainCategorySelectedList.contains(true)
            ? 'Nullstill'
            : null,
        onReset: filters.releaseMainCategorySelectedList.contains(true)
            ? () => parentSetState(() {
                  filters.releaseMainCategorySelectedList =
                      List<bool>.filled(mainCategoryList.length, false);
                  filters.releaseMainCategory = '';
                  filters.setFilters();
                })
            : null,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(mainCategoryList.length, (i) {
            final isSelected = flt.releaseMainCategorySelectedList[i];
            return GestureDetector(
              onTap: () => parentSetState(
                  () => filters.setReleaseMainCategory(i, !isSelected)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: colors.primary, width: 1)
                      : null,
                ),
                child: Text(
                  mainCategoryList[i].keys.first,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Release Allergens Filter
class _ReleaseAllergensFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const _ReleaseAllergensFilter({required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Ekskluder allergener',
        icon: Icons.no_food_outlined,
        resetLabel: filters.releaseExcludeAllergensSelectedList.contains(true)
            ? 'Nullstill'
            : null,
        onReset: filters.releaseExcludeAllergensSelectedList.contains(true)
            ? () => parentSetState(() {
                  filters.releaseExcludeAllergensSelectedList =
                      List<bool>.filled(excludeAllergensList.length, false);
                  filters.releaseExcludeAllergens = '';
                  filters.setFilters();
                })
            : null,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(excludeAllergensList.length, (i) {
            final isSelected = flt.releaseExcludeAllergensSelectedList[i];
            return GestureDetector(
              onTap: () => parentSetState(() =>
                  filters.setReleaseExcludeAllergensSelection(i, !isSelected)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: colors.primary, width: 1)
                      : null,
                ),
                child: Text(
                  excludeAllergensList[i].keys.first,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                    color: isSelected
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
