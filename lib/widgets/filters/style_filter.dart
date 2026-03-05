import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';
import '../../utils/crash_reporter.dart';
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
        icon: Icons.local_bar_outlined,
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
      builder: (_) =>
          _StyleDialogContent(filters: filters, parentSetState: parentSetState),
    );
  }
}

class _StyleDialogContent extends StatefulWidget {
  final Filter filters;
  final StateSetter parentSetState;

  const _StyleDialogContent(
      {required this.filters, required this.parentSetState});

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
    if (_filters.untappdStyleList.isEmpty) {
      _filters.getStyles().then((_) {
        if (mounted) setState(() {});
      }).catchError((Object e, StackTrace st) {
        CrashReporter.recordError(e, st, reason: 'getStyles failed');
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredStyles => _searchQuery.isEmpty
      ? _filters.categoryFilteredStyles
      : _filters.categoryFilteredStyles
          .where((s) => s.toLowerCase().contains(_searchQuery))
          .toList();

  bool get _isLoading => _filters.untappdStyleList.isEmpty && _filters.stylesLoading;

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
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
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
        final isSelected = _filters.selectedStyles.contains(style);
        return ListTile(
          dense: true,
          title: Text(style),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: colors.primary)
              : null,
          onTap: () {
            setState(() {
              isSelected
                  ? _filters.selectedStyles.remove(style)
                  : _filters.selectedStyles.add(style);
              _filters.setStyle();
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
                    if (!_filters.selectedStyles.contains(style)) {
                      _filters.selectedStyles.add(style);
                    }
                  }
                  _filters.setStyle();
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
                  _filters.setStyle();
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
