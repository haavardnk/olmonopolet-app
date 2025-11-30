import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import '../../assets/constants.dart';
import 'filter_section.dart';

class StyleFilter extends StatelessWidget {
  final StateSetter parentSetState;

  const StyleFilter({super.key, required this.parentSetState});

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    final colors = Theme.of(context).colorScheme;

    return Consumer<Filter>(
      builder: (context, flt, _) => FilterSection(
        title: 'Stil',
        resetLabel: filters.selectedStyles.isNotEmpty ? 'Nullstill' : null,
        onReset: filters.selectedStyles.isNotEmpty
            ? () => parentSetState(() {
                  filters.selectedStyles = [];
                  filters.setStyle();
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
                    filters.selectedStyles.isEmpty
                        ? 'Alle stiler'
                        : filters.selectedStyles.length == 1
                            ? filters.selectedStyles.first
                            : '${filters.selectedStyles.length} stiler valgt',
                    style: TextStyle(
                      fontSize: 13,
                      color: filters.selectedStyles.isNotEmpty
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(Icons.expand_more, size: 20, color: colors.onSurfaceVariant),
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
      builder: (_) => _StyleDialogContent(filters: filters, parentSetState: parentSetState),
    );
  }
}

class _StyleDialogContent extends StatefulWidget {
  final Filter filters;
  final StateSetter parentSetState;

  const _StyleDialogContent({required this.filters, required this.parentSetState});

  @override
  State<_StyleDialogContent> createState() => _StyleDialogContentState();
}

class _StyleDialogContentState extends State<_StyleDialogContent> {
  final _searchController = TextEditingController();
  var _searchQuery = '';

  Filter get _filters => widget.filters;

  @override
  void initState() {
    super.initState();
    _loadStylesIfNeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStylesIfNeeded() {
    if (_filters.styleChoice == 1 && _filters.untappdStyleList.isEmpty) {
      _filters.getStyles().then((_) { if (mounted) setState(() {}); });
    }
  }

  void _updateStyle() {
    if (_filters.styleChoice == 0) {
      _filters.setStyle();
    } else {
      _filters.setStyle(_filters.untappdStyleList);
    }
  }

  List<String> get _allStyles => _filters.styleChoice == 0
      ? beermonopolyStyleList.keys.toList()
      : _filters.untappdStyleList;

  List<String> get _filteredStyles => _searchQuery.isEmpty
      ? _allStyles
      : _allStyles.where((s) => s.toLowerCase().contains(_searchQuery)).toList();

  bool get _isLoading => _filters.styleChoice == 1 && _filters.untappdStyleList.isEmpty;

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
              child: Column(
                children: [
                  _buildStyleToggle(colors),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Søk etter stil...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  ),
                ],
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
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (styles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Ingen stiler funnet', style: TextStyle(color: colors.onSurfaceVariant)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: styles.length,
      itemBuilder: (context, i) {
        final style = styles[i];
        final isSelected = _filters.selectedStyles.contains(style);
        return ListTile(
          dense: true,
          title: Text(style),
          trailing: isSelected ? Icon(Icons.check_circle, color: colors.primary) : null,
          onTap: () {
            setState(() {
              isSelected ? _filters.selectedStyles.remove(style) : _filters.selectedStyles.add(style);
              _updateStyle();
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
                    if (!_filters.selectedStyles.contains(style)) _filters.selectedStyles.add(style);
                  }
                  _updateStyle();
                });
                widget.parentSetState(() {});
              },
              child: const Text('Velg alle'),
            )
          else if (_filters.selectedStyles.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _filters.selectedStyles = [];
                  _updateStyle();
                });
                widget.parentSetState(() {});
              },
              child: const Text('Nullstill'),
            ),
          const Spacer(),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Ferdig')),
        ],
      ),
    );
  }

  Widget _buildStyleToggle(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colors.surfaceContainerHighest,
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(child: _buildToggleOption('Standard', _filters.styleChoice == 0, colors, () {
            if (_filters.styleChoice != 0) {
              setState(() {
                _filters.selectedStyles = [];
                _filters.setStyleChoice(0);
              });
              widget.parentSetState(() {});
            }
          })),
          Expanded(child: _buildToggleOption('Untappd', _filters.styleChoice == 1, colors, () {
            if (_filters.styleChoice != 1) {
              setState(() {
                _filters.selectedStyles = [];
                _filters.setStyleChoice(1);
              });
              widget.parentSetState(() {});
              _loadStylesIfNeeded();
            }
          })),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isSelected, ColorScheme colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isSelected ? colors.primaryContainer : Colors.transparent,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
